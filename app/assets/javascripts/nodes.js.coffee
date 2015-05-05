# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'vis.min'
#= require 'tjax'
#= require 'md_editor'
#= require 'node_menu'

ready = ()->
  if document.getElementById('network')
    window.map = new SvgNodes.Map('#network')

    openEditor = ->
      id = if document.getElementById('node_content')
        'node_content'
      else
        'node_node_content'
      editor = new Editor(id)
    bindCloseToSubmit = ->
      $('.modal input[name="commit"]').on 'click', (e)->
        setTimeout ->
          document.querySelector('.modal').close()
          refresh()
        , 500


    
    refresh = ->
      window.map.clear()
      $.ajax('nodes', {dataType: 'script'}).done (data)->
        nodes = JSON.parse(data)
        nodes.forEach (node)->
          n = map.addNode(node)
      $.ajax('references/index', {dataType: 'script'}).done (data)->
        edges = JSON.parse data
        edges.forEach (edge)->
          map.addEdge(edge)

    map.addEventListener 'click:map', (e)->
      m = document.querySelector('.context-menu#nonode')
      an = m.querySelector('a[name="new"]')
      an.onclick = ->
        # FIXME: This is probably going to break
        # when some transformations applied.
        $.ajax("/nodes/new?x=#{e.clientX}&y=#{e.clientY}").done (data)->
          document.querySelector('.modal').open(data)
          openEditor()
          bindCloseToSubmit()
      m.open(e.pageX, e.pageY)
    map.addEventListener 'click:node', (e)->
      m = document.querySelector('.context-menu#node')
      av = m.querySelector('a[name="view"]')
      av.onclick = ->
        $.ajax("/nodes/#{e.target.node_id}").done (data)->
          document.querySelector('.modal').open(data)
      ae = m.querySelector('a[name="edit"]')
      ae.onclick = ->
        $.ajax("/nodes/edit/#{e.target.node_id}").done (data)->
          document.querySelector('.modal').open(data)
          openEditor()
          bindCloseToSubmit()
      m.open(e.pageX, e.pageY)

    map.addEventListener 'drag:map:start', ()->
      document.querySelector('.context-menu').close()
    map.addEventListener 'drag:node:start', ()->
      document.querySelector('.context-menu').close()

    search = document.querySelector('#network_panel>input')
    search.addEventListener 'keyup', (e)->
      clearTimeout search.timeout if search.timeout?
      search.timeout = setTimeout ->
        val = search.value
        if val.length < 3
          node.dim() for node in map.nodes
        else
          for node in map.nodes
            if node.text.startsWith(val)
              node.highlight()
            else
              node.dim()
        true
      , 200
    sync_anc = $('a[name="sync"]')
    sync_anc.on 'click', ()->
      $.ajax
        url: '/nodes/sync'
        method: 'PATCH'
        data:
          nodes: JSON.stringify(map.nodes.map (n)->
            { id: n.id, x: n.x, y: n.y })


    refresh()


$(document).on 'page:load', ready
$(document).ready ready
