# _           = require "lodash"
# season      = require "season"
#
# Menu        = require "menu"
#
# module.exports = class AppMenu
#     constructor         : ->
#         @template = season.readFileSync season.resolve(__dirname, "./menubar/#{process.platform}.cson")
#
#         @menu = Menu.buildFromTemplate @template, _.cloneDeep @template.menu
#         Menu.setApplicationMenu @menu

app             = require 'app'
ipc             = require 'ipc'
Menu            = require 'menu'
path            = require 'path'

season          = require 'season'
_               = require 'lodash'
{Emitter}       = require 'event-kit'

module.exports = class ApplicationMenu extends Emitter

    constructor: (options = {}) ->
        # menuJson = season.resolve(path.join(process.resourcesPath, 'app.asar', 'menus', "#{process.platform}.json"))
        # template = season.readFileSync(menuJson)
        # console.log season.resolve()
        template = season.readFileSync path.join(__dirname, "./menubar/#{process.platform}.cson")

        @template = @translateTemplate(template.menu, options.pkg)

    attachToWindow: (window) ->
        @menu = Menu.buildFromTemplate(_.cloneDeep(@template))
        Menu.setApplicationMenu(@menu)

    wireUpMenu: (menu, command) ->
        menu.click = => @emit(command)

    translateTemplate: (template, pkgJson) ->
        emitter = @emit

        for item in template
            item.metadata ?= {}

            if item.label
                item.label = (_.template(item.label))(pkgJson)

            if item.command
                @wireUpMenu item, item.command

            @translateTemplate(item.submenu, pkgJson) if item.submenu

        return template

    acceleratorForCommand: (command, keystrokesByCommand) ->
        firstKeystroke = keystrokesByCommand[command]?[0]
        return null unless firstKeystroke

        modifiers = firstKeystroke.split('-')
        key = modifiers.pop()

        modifiers = modifiers.map (modifier) ->
        modifier.replace(/shift/ig, "Shift")
            .replace(/cmd/ig, "Command")
            .replace(/ctrl/ig, "Ctrl")
            .replace(/alt/ig, "Alt")

        keys = modifiers.concat([key.toUpperCase()])
        keys.join("+")
