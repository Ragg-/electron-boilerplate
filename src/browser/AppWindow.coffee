BrowserWindow       = require "browser-window"
{Emitter}           = require "event-kit"

module.exports = class AppWindow extends Emitter
    _opts           : null
    browserWindow   : null

    constructor     : (options = {}) ->
        super

        @_opts = options
        global.app.addWindow(@)

        @setupWindow()
        @handleEvents()

    setupWindow     : ->
        @browserWindow = w = new BrowserWindow(@_opts)
        w.loadUrl(@_opts.url) if @_opts.url?

        if @_opts.devMode
            w.openDevTools {detach: true}

        return

    handleEvents    : ->
        @browserWindow.on "closed", @dispose.bind(@)
        @browserWindow.on "focus", =>
            global.app.setLastFocusedWindow @

        if @_opts.devMode
            @browserWindow.webContents.on "did-start-loading", =>
                try @_electronConnect = require('electron-connect').client.create(@browserWindow)
                @browserWindow.webContents.executeJavaScript "try{require('electron-connect').client.create();}catch(e){}"

        return


    dispose         : ->
        @browserWindow = null
        global.app.removeWindow(@)
        super
