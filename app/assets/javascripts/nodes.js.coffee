# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'vis.min'
#= require 'tjax'
#= require 'md_editor'
#= require 'node_menu'

ready = ()->
  if document.getElementById('network')
    vis.data = {
      nodes: [],
      edges: []
    }

    $.ajax('nodes', {dataType: 'script'}).done (data)->
      vis.data.nodes = JSON.parse data
      vis.net.setData({ nodes: vis.data.nodes, edges: vis.data.edges})
    $.ajax('references/index', {dataType: 'script'}).done (data)->
      vis.data.edges = JSON.parse data
      vis.net.setData({ nodes: vis.data.nodes, edges: vis.data.edges})

    opt = {
      width: '100%',
      height: '100%'
      stabilize: true,
      edges: {
        style: 'arrow',
        color: '#306060',
        arrowScaleFactor: 0.7
      }
      nodes: {
        color: { background: '#a05050' }
      }
    }


    vis.net = new vis.Network(
      document.getElementById 'network',
    vis.data, opt)


    $(window).on 'resize', ()->
      vis.net.redraw()

    menu = new Menu('network',
      [{ label: 'View' },
      { label: 'Edit content' },
      { label: 'Add child node' }]
    )
    inew = $('#instant_new')

    vis.net.on 'select', (prop)->
      ids = prop.nodes
      inew.addClass 'hidden'
      if ids.length > 0
        pos = vis.net.getPositions(ids[0])[ids[0]]
        posDOM = vis.net.canvasToDOM(pos)
        netDOM = $('#network').offset()
        menu.items[0].url = "/nodes/#{ids[0]}"
        menu.items[1].url = "/nodes/edit/#{ids[0]}"
        menu.items[2].url = "/nodes/instant_new_for/#{ids[0]}"
        menu.open(
          Math.ceil(posDOM.x + netDOM.left),
          Math.ceil(posDOM.y + netDOM.top)
        )
      else
        menu.close()
    vis.net.on 'dragStart', ()->
      vis.net.selectNodes([])
      menu.close()
    vis.net.on 'viewChanged', ()->
      vis.net.selectNodes([])
      menu.close()


  if document.getElementById('editor_pair')
    id = if document.getElementById('node_content')
      'node_content'
    else
      'node_node_content'
    editor = new Editor(id)
  if document.getElementById('search')
    search = $('#search')
    search.on 'change', ()->
      #return false unless search.val().length > 3
      query = search.val()
      results = $.ajax("/nodes/search?query=#{query}", {
        async: false,
        dataType: 'script'
      }).responseText
      alert JSON.stringify(results)
$(document).on 'page:load', ready
$(document).ready ready
