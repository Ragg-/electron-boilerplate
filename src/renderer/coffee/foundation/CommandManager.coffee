ipc             = require "ipc"
{Disposable}    = require "event-kit"
EventEmitter    = require "eventemitter3"

###
* Renderer side Command manager
###
class CommandManager extends EventEmitter
    emitter         : null

    constructor     : ->
        super()

        @emitter = new EventEmitter()
        @handleEvents()

        console.info "CommandManager started."

    handleEvents    : ->
        ipc.on "command", @received.bind(@)
        return

    ###
    Sender & Receiver
    ###

    dispatch        : (command, args...) ->
        @emit command, args...
        return

    send            : (command, args...) ->
        ipc.send "command", command, args...
        @emitter.emit "did-send", command, args...
        return

    received        : (command, args...) ->
        @emit command, args...
        @emitter.emit "did-receive", command, args...
        return

    ###
    Event handler register (for use develop)
    ###
    onDidSend       : (fn) ->
        @emitter.on "did-send", fn
        new Disposable => @off "did-send", fn

    onDidReceive    : (fn) ->
        @emitter.on "did-receive", fn
        new Disposable => @off "did-receive", fn


module.exports = new CommandManager
