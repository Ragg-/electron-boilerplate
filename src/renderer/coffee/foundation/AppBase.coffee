CommandManager = require "foundation/CommandManager"

module.exports = class AppBase
    command         : null

    constructor     : ->
        @command    = CommandManager
