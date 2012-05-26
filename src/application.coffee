$ = jQuery

class Item extends Spine.Model
  @configure "Item", "name", "done"

  @extend Spine.Model.Local

  @active: ->
    @select (item) -> !item.done

  @done: ->
    @select (item) -> !!item.done

  @destroyDone: ->
    rec.destroy() for rec in @done()

class Items extends Spine.Controller
  events:
   "change   input[type=checkbox]": "toggle"
   "click    .destroy":             "remove"
   "dblclick .view":                "edit"
   "keypress input[type=text]":     "blurOnEnter"
   "blur     input[type=text]":     "close"

  elements:
    "input[type=text]": "input"

  constructor: ->
    super
    @item.bind("update",  @render)
    @item.bind("destroy", @release)

  render: =>
    @replace($("#taskTemplate").tmpl(@item))
    @

  toggle: ->
    @item.done = !@item.done
    @item.save()

  remove: ->
    @item.destroy()

  edit: ->
    @el.addClass("editing")
    @input.focus()

  blurOnEnter: (e) ->
    if e.keyCode is 13 then e.target.blur()

  close: ->
    @el.removeClass("editing")
    @item.updateAttributes({name: @input.val()})

class Checklist extends Spine.Controller
  events:
    "submit form":   "create"
    "click  .clear": "clear"

  elements:
    ".items":     "items"
    ".countVal":  "count"
    ".clear":     "clear"
    "form input": "input"

  constructor: ->
    super
    Item.bind("create",  @addOne)
    Item.bind("refresh", @addAll)
    Item.bind("refresh change", @renderCount)
    Item.fetch()

  addOne: (Item) =>
    view = new Items(item: Item)
    @items.append(view.render().el)

  addAll: =>
    Item.each(@addOne)

  create: (e) ->
    e.preventDefault()
    Item.create(name: @input.val())
    @input.val("")

  clear: ->
    Item.destroyDone()

  renderCount: =>
    active = Item.active().length
    @count.text(active)

    inactive = Item.done().length
    if inactive
      @clear.show()
    else
      @clear.hide()

$ ->
  new Checklist(el: $("#Items"))
