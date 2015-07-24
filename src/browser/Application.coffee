AppMenu         = require "./AppMenu"
AppWindow       = require "./AppWindow"

fs              = require "fs"
ipc             = require "ipc"

assign          = (dest, objects...) ->
    for o in objects
        dest[k] = v for k, v of o
    dest


module.exports = class Application
    _windows        : null
    _options        : null
    _navbar         : null
    packageJson     : null

    constructor     : (options = {}) ->
        global.app = @

        @_windows       = []
        @_options       = options
        @packageJson    = require("../package.json")

        new AppWindow assign {}, options,
            url     : "file://#{__dirname}/../renderer/index.html"

        @handleEvents()

    addWindow       : (window) ->
        @_windows.push window
        return

    removeWindow    : (window) ->
        @_windows.splice index, 1 for index, w of @_windows when w is window
        return

    handleEvents    : ->
        ipc.on "open", (e, options) ->
            options ?= @_opts
            new AppWindow(options)
