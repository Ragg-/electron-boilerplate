BrowserWindow       = require "browser-window"
EventEmitter        = require "eventemitter3"

module.exports = class AppWindow extends EventEmitter
    options         : null
    browserWindow   : null

    constructor     : (options = {}) ->
        super

        @options = options
        global.app.addWindow(@)

        # Created window is focused.
        # But not "focus" event is fired.
        global.app.setLastFocusedWindow(@)

        @setupWindow()
        @handleEvents()

    setupWindow     : ->
        @browserWindow = w = new BrowserWindow(@options)
        w.loadUrl(@options.url) if @options.url?

        return

    handleEvents    : ->
        # delegate browserWindow events
        # https://github.com/atom/electron/blob/02bdace366f38271b5c186412f42810ecb06e99e/docs/api/browser-window.md
        [
            "page-title-updated"
            "close"
            "closed"
            "unresponsive"
            "responsive"
            "blur"
            "focus"
            "maximize"
            "unmaximize"
            "minimize"
            "restore"
            "resize"
            "move"
            "moved"
            "enter-full-screen"
            "leave-full-screen"
            "enter-html-full-screen"
            "leave-html-full-screen"
            "devtools-opened"
            "devtools-closed"
            "devtools-focused"
        ].forEach (name) =>
            @browserWindow.on name, => @emit name, arguments...

        @on "closed", @dispose.bind(@)
        @on "focus", =>
            global.app.setLastFocusedWindow @

        if global.app.isDevMode()
            @browserWindow.webContents.on "dom-ready", =>
                try @_electronConnect = require('electron-connect').client.create(@browserWindow)
                @browserWindow.webContents.executeJavaScript "try{require('electron-connect').client.create();}catch(e){}"

        return


    dispose         : ->
        @browserWindow = null
        global.app.removeWindow(@)
