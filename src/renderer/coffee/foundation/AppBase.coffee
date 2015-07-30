CommandManager = require "foundation/CommandManager"
ContextMenuManager = require "foundation/ContextMenuManager"

module.exports = class AppBase
    command         : null

    constructor     : ->
        @command    = CommandManager
        @contextMenu    = ContextMenuManager

        @handleEvents()

    handleEvents    : ->
        @contextMenu.onDidClickCommandItem (command) =>
            @command.dispatch command

        window.addEventListener "contextmenu", (e) =>
            setTimeout =>
                # Why use setTimeout???
                # event.path is buggy, execute `event.path` immediately,
                # path is broken... (path array element is only `window`)
                # WebKit has an bug?
                @contextMenu.showForElementPath e.path
            , 0

        return
