# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'vis.min'
#= require 'tjax'
#= require 'md_editor'

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
      hierarchicalLayout: {
        direction: "DU",
        levelSeparation: 100
      },
      stabilize: true,
      edges: {
        style: 'arrow'
      }
    }

    vis.net = new vis.Network(
      document.getElementById 'network',
    vis.data, opt)

    menu = $('#network_menu')
    inew = $('#instant_new')

    vis.net.on 'select', (prop)->
      ids = prop.nodes
      inew.addClass 'hidden'
      if ids.length > 0
        pos = vis.net.getPositions(ids[0])[ids[0]]
        posDOM = vis.net.canvasToDOM(pos)
        netDOM = $('#network').offset()
        menu.css('left', "#{Math.ceil (posDOM.x + netDOM.left)}px")
        menu.css('top', "#{Math.ceil (posDOM.y + netDOM.top)}px")
        $('#network_menu_open').attr('href', "/nodes/#{ids[0]}")
        $('#network_menu_edit').attr('href', "/nodes/edit/#{ids[0]}")
        $('#network_menu_add_child').on 'click', ()->
          menu.addClass 'hidden'
          inew.removeClass 'hidden'
          inew.css('left', "#{Math.ceil (posDOM.x + netDOM.left)}px")
          inew.css('top', "#{Math.ceil (posDOM.y + netDOM.top)}px")
          inew.html(
            $.ajax("nodes/instant_new_for/#{ids[0]}", { async: false }).responseText
          )
        menu.removeClass 'hidden'
      else
        menu.addClass 'hidden'
    vis.net.on 'dragStart', (prop)->
      menu.addClass 'hidden'
      inew.addClass 'hidden'


  if document.getElementById('editor_pair')
    editor = new Editor('node_content')
$(document).on 'page:load', ready
$(document).ready ready
