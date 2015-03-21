# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'md5.min'

class window.Tjax
  constructor: ()->
    @id = 0
    window.setInterval(this.cleanup.bind(this), 5000)

  delayed: (f, timeout) ->
    window.setTimeout(f.bind(this), timeout)

  cleanup: ->
    for i in [0..sessionStorage.length]
      k = sessionStorage.key(i)
      if k && $("span[hash^='#{k}']").length == 0
        sessionStorage.removeItem(k)

  inlineTag: (id) ->
    "<span id=\"tjax_#{id}\"></span>"
  blockTag: (id) ->
    "<p id=\"tjax_#{id}\"></p>"

  addInline: (src) ->
    src = "$ #{src} $"
    this.insertImage(src)
    @id += 1
    return this.inlineTag(@id - 1)

  addBlock: (src) ->
    src = "\\[ #{src} \\]"
    this.insertImage(src)
    @id += 1
    return this.blockTag(@id - 1)

  insertImage: (src) ->
    hash = md5(src)
    if item = sessionStorage.getItem(hash)
      this.insertImageDOM(@id, hash, item)
    else
      id = @id
      $.ajax('/tjax/convert', {
        'data': 'str=' + src,
        'type': 'POST'
      }).done(((resp)->
        img = "<img src=\"data:image/png;base64,#{resp}\"/>"
        this.insertImageDOM(id, hash, img)).bind(this))

  insertImageDOM: (id, hash, img) ->
    this.delayed( ->
      if el = document.getElementById("tjax_#{id}")
        el.setAttribute('hash', hash)
        el.innerHTML = img
        sessionStorage.setItem(hash, img)
    , 100)


