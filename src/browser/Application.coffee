AppMenu         = require "./AppMenu"
AppWindow       = require "./AppWindow"

fs              = require "fs"
ipc             = require "ipc"
EventEmitter    = require "eventemitter3"
{Disposable}    = require "event-kit"

module.exports = class Application extends EventEmitter
    @instance       : null

    windows         : null
    lastFocusedWindow   : null
    command         : null
    options         : null
    packageJson     : null

    constructor     : (options = {}) ->
        super()

        @windows        = new Set
        @options        = options
        @packageJson    = require "../package.json"
        @command        = require "./CommandManager"

        Object.defineProperty Application, "instance",
            value   : @

        @handleEvents()

    handleEvents    : ->
        ipc.on "open", (e, options) ->
            options ?= @options
            new AppWindow(options)

        @command.on "app:open", (e, options) ->
            new AppWindow(options)
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
