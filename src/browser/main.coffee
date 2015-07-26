fs              = require "fs"
path            = require "path"

app             = require "app"
Application     = require "./Application"
AppWindow       = require "./AppWindow"

process.on "uncaughtException", (error = {}) ->
    appRoot = new RegExp(path.join(__dirname, "../"), "g")
    process.stderr.write("\u001b[1;31m[Error]\u001b[0;31m#{error.message}\n\u001b[m\n") if error.message?
    process.stderr.write("\u001b[1;31m[Stack]\u001b[0;31m#{error.stack.replace(appRoot, "")}\u001b[m\n") if error.stack?
    return

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
        global.app.command.dispatch "app:new-window"

    return
