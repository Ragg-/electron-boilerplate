Menu            = require "menu"
path            = require "path"

_               = require "lodash"
EventEmitter    = require "eventemitter3"

module.exports = class MenuManager extends EventEmitter
    winMenuMap      : null
    defaultTemplate : null

    constructor     : ->
        @winMenuMap = new WeakMap

        # Deferred loading for use `global.app` in menu definition file.
        # If load it in here, menu definition and global.app.constructor to become co-dependent
        # Load menu definition then use the @getDefaultTemplate method instead of require here.
        # @defaultTemplate = require "./menus/#{process.platform}"

        @handleEvents()

        console.info "\u001b[36mMenuManager started.\u001b[m"

    handleEvents    : ->
        return

    ###
    Menu building helpers
    ###

    getDefaultTemplate  : ->
        @defaultTemplate = require "../config/menus/#{process.platform}" unless @defaultTemplate?
        @defaultTemplate

    buildFromTemplate   : (template) ->
        Menu.buildFromTemplate @translateTemplate(template)

    translateTemplate   : (template) ->
        items = _.cloneDeep(template)

        for item in items
            item.metadata ?= {}

            item.click = @wrapClick(item)
            item.submenu = @translateTemplate(item.submenu) if item.submenu

        items

    wrapClick           : (item) ->
        clickListener = item.click

        =>
            Menu.sendActionToFirstResponder?(item.selector) if item.selector?

            activeMenu = @getActiveMenu()
            clickListener(item, activeMenu) if typeof clickListener is "function"
            @emit("did-click-item", item, activeMenu)
            @emit("did-click-command-item", item.command, item, activeMenu) if item.command?
            return

    ###
    Menu controling
    ###

    getActiveMenu       : ->
        Menu.getApplicationMenu()

    attachMenu          : (window) ->
        menu = @winMenuMap.get window

        unless menu?
            # console.log @defaultTemplate
            menu = @buildFromTemplate @getDefaultTemplate()
            @winMenuMap.set window, menu

        menu

    changeActiveMenu    : (window) ->
        menu = @winMenuMap.get window
        menu = @attachMenu(window) unless menu?

        Menu.setApplicationMenu(menu)
        @emit "did-change-active-menu"
        return

    ###
    Event handlers
    ###

    onDidClickCommandItem   : (fn) ->
        @on "did-click-command-item", fn
        return

    onDidChangeActiveMenu   : (fn) ->
        @on "did-change-active-menu", fn
        return

    onDidClickItem          : (fn) ->
        @on "did-click-item", fn
        return
