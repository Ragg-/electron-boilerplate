AppWindow       = require "./AppWindow"
MenuManager     = require "./MenuManager"

app             = require "app"
fs              = require "fs"
ipc             = require "ipc"
EventEmitter    = require "eventemitter3"
{Disposable}    = require "event-kit"

assign          = (dest, objects...) ->
    for o in objects
        dest[k] = v for k, v of o
    dest

module.exports = class Application extends EventEmitter
    @instance       : null

    windows         : null
    lastFocusedWindow   : null
    command         : null
    menu            : null
    options         : null
    packageJson     : null

    constructor     : (options = {}) ->
        super()

        @windows        = new Set
        @options        = options
        @packageJson    = require "../package.json"
        @command        = require "./CommandManager"
        @menu           = new MenuManager

        Object.defineProperty Application, "instance",
            value   : @

        @handleEvents()

    handleEvents    : ->
        ipc.on "open", (e, options) ->
            options ?= @options
            new AppWindow(options)

        # MenuManager events

        @onDidWindowAdd (window) =>
            @menu.attachMenu window

        @onDidFocusedWindowChange (window) =>
            @menu.changeActiveMenu window

        @menu.onDidClickCommandItem (command) =>
            @command.dispatch command

        @handleAppCommands()
        @handleWindowCommands()


        return

    handleAppCommands       : ->
        @command.on "app:new-window", =>
            new AppWindow assign {}, @options,
                url     : "file://#{__dirname}/../renderer/index.html"
            return

        @command.on "app:quit", =>
            app.quit()
            return

        return


    handleWindowCommands    : ->
        bindCommandToBwAction = (cmd, method) =>
            @command.on cmd, =>
                @getLastFocusedWindow()?.browserWindow[method]()
                return

        bindCommandToBwAction "window:toggle-dev-tools", "toggleDevTools"
        bindCommandToBwAction "window:reload", "reload"

        @command.on "window:close", =>
            w = @getLastFocusedWindow()?.browserWindow
            return unless w?

            if w.devToolsWebContents?
                w.closeDevTools()
            else if w.isFocused()
                w.close()

            return

        return

    ###
    Window Managements
    ###

    addWindow       : (window) ->
        preSize = @windows.size
        if @windows.add(window).size isnt preSize
            @emit "did-window-added", window
        return

    removeWindow    : (window) ->
        if @windows.delete(window)
            @emit "did-window-remove"
        return

    setLastFocusedWindow    : (window) ->
        @lastFocusedWindow = window
        @emit "did-focused-window-changed", window
        return

    getLastFocusedWindow    : ->
        @lastFocusedWindow


    ###
    Event handler register
    ###

    on              : (event, listener) ->
        super
        new Disposable => @off event, listener

    onDidWindowAdd      : (fn) ->
        @on "did-window-added", fn

    onDidWindowRemove   : (fn) ->
        @on "did-window-remove", fn

    onDidFocusedWindowChange    : (fn) ->
        @on "did-focused-window-changed", fn
