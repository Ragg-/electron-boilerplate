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

    setupWindow     : ->
        @browserWindow = w = new BrowserWindow(@_opts)
        w.loadUrl(@_opts.url) if @_opts.url?

        # Developer mode
        if @_opts.devMode
            @_electronConnect = require('electron-connect').client.create(w)
            w.openDevTools {detach: true}
            w.webContents.executeJavaScript "require('electron-connect').client.create()"

        return

    handleEvents    : ->
        console.log @browserWindow.on "closed", @dispose.bind(@)

    dispose         : ->
        @browserWindow = null
        global.app.removeWindow(@)
        super
