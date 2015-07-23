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

        # @createWindow(options)
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


# {EventEmitter}      = require "events"
#
# module.exports = class AppWindow extends BrowserWindow
#     _opts           : null
#
#     constructor     : (options = {}) ->
#         global.app = @
#
#         @_opts = options
#
#
#         new AppWindow(options)
#
#     addWindow       : (options = {}) ->
#         appWindow = new AppWindow
#             width   : 800
#             height  : 1000
#             url     : "file://#{__dirname}/../renderer/index.html"
#
#
#         appWindow.on "closed", =>
#             index = @_windows.indexOf appWindow
#             @_windows.splice index, 1
#             appWindow = null
#
#         menu = new AppMenu(pkg: @packageJson)
#         menu.attachToWindow appWindow
#
#         appWindow.on "closed", =>
#             @removeWindow appWindow
#

#
#         @_windows.push appWindow
#         return
