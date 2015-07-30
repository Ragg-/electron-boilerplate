Remote          = require "remote"
Menu            = Remote.require("menu")

_               = require "lodash"
{Disposable}    = require "event-kit"
EventEmitter    = require "eventemitter3"

module.exports = class ContextMenuManager extends EventEmitter
    lastPoppedItem : null
    selectorMenuMap : null

    constructor : ->
        @lastPoppedItem = null
        @selectorMenuMap = {}

    ###
    Context menu management methods
    ###

    add : (selector, menu) ->
        unless Array.isArray(menu)
            throw new TypeError("Menu list must be array.")

        smm = @selectorMenuMap
        smm[selector] = [] unless smm[selector]?
        smm[selector].push menu
        return


    remove : (selector, menu) ->
        smm = @selectorMenuMap
        return unless smm[selector]?

        for menu, i in smm[selector]
            smm[selector].splice(i, 1) if smm is menu
            return true

        false

    clear : ->
        @selectorMenuMap = {}
        return

    ###
    Context menu builder methods
    ###

    getActiveMenu : (active) ->
        @lastPoppedItem

    wrapClick : (item) ->
        clickListener = item.click

        =>
            Menu.sendActionToFirstResponder?(item.selector) if item.selector?

            activeMenu = @getActiveMenu()
            clickListener(item, activeMenu) if typeof clickListener is "function"
            @emit("did-click-item", item, activeMenu)
            @emit("did-click-command-item", item.command, item, activeMenu) if item.command?
            return

    translateTemplate : (template) ->
        items = _.cloneDeep(template)

        for item in items
            item.metadata ?= {}

            item.click = @wrapClick(item)
            item.submenu = @translateTemplate(item.submenu) if item.submenu

        items

    templateForElement : (el) ->
        unshift = Array::unshift
        smm = @selectorMenuMap
        presentMenus = []

        for selector, menuList of smm
            continue unless el.matches(selector)
            unshift.apply(presentMenus, item) for item in menuList

        # Remove first, last, consecutive separator
        last = presentMenus.length - 1
        presentMenus.splice(0, 1) if presentMenus[0]?.type is "separator"
        presentMenus.splice(last, 1) if presentMenus[last]?.type is "separator"

        for item, i in presentMenus
            prevItem = presentMenus[i - 1]
            presentMenus.splice(i, 1) if prevItem? and prevItem.type is "separator" and item.type is "separator"

        @translateTemplate(presentMenus)

    ###
    Context menu display methods
    ###

    showForElement : (el) ->
        menu = Menu.buildFromTemplate(@templateForElement(el))
        menu.popup(Remote.getCurrentWindow())
        return

    showForElementPath : (path) ->
        push = Array::push

        elements = path.filter (el) ->
            el instanceof HTMLElement

        menuItems = elements.reduce((menus, el) =>
            push.apply(menus, @templateForElement(el))
            menus
        , [])

        menu = Menu.buildFromTemplate(menuItems)
        @lastPoppedItem = menu
        menu.popup(Remote.getCurrentWindow())
        return


    ###
    Event handlers
    ###
    on : (event, listener) ->
        super
        new Disposable => @off event, listener

    onDidClickCommandItem : (fn) ->
        @on "did-click-command-item", fn

    onDidClickItem : (fn) ->
        @on "did-click-command-item", fn


module.exports = new ContextMenuManager
