g       = require "gulp"
$       = do require "gulp-load-plugins"

fs      = require "fs"
path    = require "path"
{spawn, fork} = require("child_process")

throttle = (interval, fn) ->
  lastTime = Date.now() - interval

  return ->
    return if (lastTime + interval) >= Date.now()
    lastTime = Date.now()

    fn()
    return

envRequireConfig = (file) ->
    exports = {}

    for env in ["common", BUILD_ENV]
        filePath = "./gulp_config/#{env}/#{file}"
        exports[k] = v for k, v of require(filePath) if fs.existsSync(filePath)

    return exports

# Use for renderer only
genPaths = (dir, ext, withinDirs = []) ->
    if (ext isnt null or ext isnt "") and ext[0] isnt "."
        ext = ".#{ext}"

    if dir isnt ""
        dir = "#{dir}/"

    return [
        "#{gulpOption.sourceDir}/renderer/#{dir}**/*#{ext}"
        "!#{gulpOption.sourceDir}/renderer/#{dir}**/_*#{ext}"
        "!#{gulpOption.sourceDir}/renderer/#{dir}_*/**"
    ].concat withinDirs


BUILD_ENV   = "dev"
gulpOption  = envRequireConfig "gulp.coffee"


#
# Script copy task for Electron
#
g.task "copy-browser-files", ->
    g.src [
        "src/**"
        "!src/renderer/**"
    ]
        .pipe g.dest(gulpOption.buildDir)

#
# Webpack Task
#
g.task "webpack", (cb) ->
    g.src genPaths("coffee", ".coffee").concat(genPaths("js", ".js"))
        .pipe $.plumber()
        .pipe $.changed("#{gulpOption.buildDir}/js/")
        .pipe $.webpack(envRequireConfig("webpack.coffee"))
        .pipe g.dest("#{gulpOption.buildDir}/renderer/js/")

#
# JavaScript copy Task
#
g.task "vendor_js", ->
    g.src genPaths("vendor_js", ".js")
        .pipe $.plumber()
        .pipe $.changed("#{gulpOption.buildDir}/#{gulpOption.js.vendorJsDir}/")
        .pipe g.dest("#{gulpOption.buildDir}/renderer/#{gulpOption.js.vendorJsDir}/")

#
# Stylus Task
#
g.task "stylus", ->
    g.src genPaths("styl", ".styl")
        .pipe $.plumber()
        .pipe $.changed("#{gulpOption.buildDir}/css/")
        .pipe $.stylus(envRequireConfig("stylus.coffee"))
        .pipe g.dest("#{gulpOption.buildDir}/renderer/css/")

#
# Jade Task
#
g.task "jade", ->
    g.src genPaths("", "jade", ["!#{gulpOption.sourceDir}/coffee/**/*.jade"])
        .pipe $.plumber()
        .pipe $.changed("#{gulpOption.buildDir}/")
        .pipe $.jade()
        .pipe $.prettify()
        .pipe g.dest("#{gulpOption.buildDir}/renderer/")

#
# Image minify Task
#
g.task "images", ->
    g.src genPaths("img", "{png,jpg,jpeg,gif}")
        .pipe $.plumber()
        .pipe $.changed("#{gulpOption.buildDir}/img/")
        .pipe $.imagemin(envRequireConfig("imagemin.coffee"))
        .pipe g.dest("#{gulpOption.buildDir}/renderer/img/")

#
# package.json copy Task
#
g.task "package-json", (cb) ->
    string = fs.readFileSync "./package.json", {encoding: "utf8"}
    json = JSON.parse(string)

    delete json.devDependencies
    newString = JSON.stringify json, null, "  "

    fs.writeFileSync path.join(gulpOption.sourceDir, "package.json"), newString, {encoding: "utf8"}
    fs.writeFileSync path.join(gulpOption.buildDir, "package.json"), newString, {encoding: "utf8"}
    cb()

#
# File watch Task
#
g.task "watch", ->
    rendererSrcRoot = "#{gulpOption.sourceDir}/renderer/"

    $.watch [
        "src/**"
        "!src/renderer/"
    ], ->
        g.start ["copy-browser-files"]

    $.watch [
        "#{rendererSrcRoot}/coffee/**/*.{coffee,jade,cson}"
        "#{rendererSrcRoot}/js/**/*.{js,jade,cson}"
    ], ->
        g.start ["webpack"]

    $.watch [
        "#{rendererSrcRoot}/vendor_js/**/*.js"
    ], ->
        g.start ["vendor_js"]

    $.watch [
        "#{rendererSrcRoot}/styl/**/*.styl"
    ], ->
        g.start ["stylus"]

    $.watch [
        "#{rendererSrcRoot}/**/*.jade"
        "!#{rendererSrcRoot}/coffee/**/*.jade"
        "!#{rendererSrcRoot}/js/**/*.jade"
    ], ->
        g.start ["jade"]

    $.watch [
        "package.json"
    ], ->
        g.start ["package-json"]

    $.watch [
        "#{rendererSrcRoot}/img/**/*.{png,jpg,jpeg,gif}"
    ], ->
        g.start ["images"]


g.task "packaging", (cb) ->
    pack = require "electron-packager"
    pack envRequireConfig("electron.coffee"), cb

#
# build
#
g.task "production", (cb) ->
    BUILD_ENV = "production"
    gulpOption  = envRequireConfig "gulp.coffee"

    g.start ["build", "packaging"]

    return

#
# Gulpfile watcher
#
g.task "self-watch", ->
    proc    = null

    spawnChildren = ->
        proc.kill() if proc?
        proc = fork require.resolve("gulp/bin/gulp"), ["dev"], {silent: false}

    $.watch ["Gulpfile.coffee", "./gulp_config/**"], ->
        spawnChildren()

    spawnChildren()

#
# Electron startup task
#
g.task "electron-dev", do ->
    electron = require('electron-connect').server.create
        path    : gulpOption.buildDir

    rendererDir = path.join(gulpOption.buildDir, "renderer/")

    restart = throttle 2000, -> electron.restart "--dev"
    reload = throttle 2000, -> electron.reload()

    return ->
        electron.start("--dev")

        $.watch [gulpOption.buildDir, "!#{rendererDir}"], restart
        $.watch rendererDir, reload


#
# Define default
#
g.task "build", ["webpack", "stylus", "jade", "images", "copy-browser-files", "package-json"]
g.task "publish", ["production"]
g.task "dev", ["build", "watch"]
g.task "default", ["self-watch", "electron-dev"]
