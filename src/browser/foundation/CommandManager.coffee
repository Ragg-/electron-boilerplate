ipc             = require "ipc"
EventEmitter    = require "eventemitter3"

###
* Browser side Command manager
###
class CommandManager extends EventEmitter
    emitter         : null

    constructor     : ->
        super()

        @emitter = new EventEmitter()
        @handleEvents()

    handleEvents        : ->
        ipc.on "command", @received.bind(@)
        return

    ###
    Sender & Receiver
    ###

    dispatch        : (command, args...) ->
        @emit command, args...
        @send command, args...
        return

    send            : (command, args...) ->
        window = global.app.getLastFocusedWindow()
        @sendToWindow window, command, args...
        return

    sendToWindow    : (window, command, args...) ->
        return unless window?.browserWindow?.webContents?

        window.browserWindow.webContents.send "command", command, args...
        @emitter.emit "did-send", window, command, args...
        return

    received         : (e, command, args...) =>
        @emit command, args...
        @emitter.emit "did-receive", command, args...
        return

    ###
    Event handler register (for use develop)
    ###

    onDidSend       : (fn) ->
        @emitter.on "did-send", fn
        return

    onDidReceive    : (fn) ->
        @emitter.on "did-receive", fn
        return

module.exports = new CommandManager
