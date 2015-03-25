#= require 'marked'
#= require 'tjax'
#= require 'ace/ace'
#= require 'ace/worker-html'
#= require 'ace/theme-solarized_dark'
#= require 'ace/mode-markdown'
#
class window.Editor
  constructor: (input_field) ->
    @input_field = input_field
    $("##{@input_field}").css('visibility', 'hidden')
    @theme_prefix = 'ace/theme/'
    @ttimer = null
    @aedit = ace.edit('md_editor')
    @aedit.setValue($("##{@input_field}").val())
    mdm = require('ace/mode/markdown').Mode
    @aedit.getSession().setMode(new mdm())

    this.setTheme 'solarized_dark'
    $('#md_render').html(marked @aedit.getValue() )

    @aedit.getSession().on 'change', this._change.bind(this)
    @aedit.getSession().on 'changeScrollTop', this._syncScrolls.bind(this)

    window.editor = this

  _change: (e)->
    clearTimeout(@ttimer) if @ttimer
    @ttimer = window.setTimeout(() ->
      $('#md_render').html(marked editor.aedit.getValue())
      true
    , 1000)
    $("##{@input_field}").val(editor.aedit.getValue())
    true

  setTheme: (name) ->
    @aedit.setTheme @theme_prefix + name

  _syncScrolls: (val) ->
      fs = parseInt $('#md_render').css('font-size')
      $('#md_render').scrollTop(val * fs)
