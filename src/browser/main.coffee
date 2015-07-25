fs              = require "fs"
path            = require "path"

app             = require "app"
Application     = require "./Application"
AppWindow       = require "./AppWindow"

process.on "uncaughtException", (error = {}) ->
    process.stderr.write("[Error]#{error.message}\n") if error.message?
    process.stderr.write("[Stack]#{error.stack}\n") if error.stack?
    return

assign          = (dest, objects...) ->
    for o in objects
        dest[k] = v for k, v of o
    dest

parseCommandLine = ->
    version = app.getVersion()

    yargs = require("yargs")
        .boolean("dev")
        .describe("dev", "Run development mode")

        .boolean("help")
        .describe("help", "Show command line help")
        .alias("help", "h")

        .boolean("version")
        .describe("version", "Show version")
        .alias("version", "v")

    args = yargs.parse(process.argv[1..])

    if args.help
        yargs.showHelp("error")
        process.exit(0)

    if args.version
        process.stdout.write("#{version}\n")
        process.exit(0)

    devMode     = args["dev"]

    {devMode}

do ->
    args = parseCommandLine()

    app.on "window-all-closed", ->
        app.quit() if process.platform isnt "darwin"
        return

    app.on "ready", ->
        global.app = new Application(args)

        new AppWindow assign {}, args,
            url     : "file://#{__dirname}/../renderer/index.html"

    return
