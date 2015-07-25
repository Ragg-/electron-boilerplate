AppMenu         = require "./AppMenu"
AppWindow       = require "./AppWindow"

fs              = require "fs"
ipc             = require "ipc"

assign          = (dest, objects...) ->
    for o in objects
        dest[k] = v for k, v of o
    dest

    windows         : null
    options         : null
    packageJson     : null

    constructor     : (options = {}) ->

        @windows        = []
        @options        = options
        @packageJson    = require "../package.json"

        new AppWindow assign {}, options,
            url     : "file://#{__dirname}/../renderer/index.html"

        @handleEvents()

    addWindow       : (window) ->
        @windows.push window
        return

    removeWindow    : (window) ->
        @windows.splice index, 1 for index, w of @windows when w is window
        return

    handleEvents    : ->
        ipc.on "open", (e, options) ->
            options ?= @_opts
            new AppWindow(options)
