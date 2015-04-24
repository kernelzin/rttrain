# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



#
# rect with line handlers
#
paper = new Raphael(0, 0, 500, 500)


createRect = (x, y, width, height) ->
  rect = paper.rect(x, y, width, height).attr(
    'fill': 'white'
    'stroke': 'red')
  topCtrl = paper.circle(x + width / 2, y, 5).attr('fill': 'red')
  bottomCtrl = paper.circle(x + width / 2, y + height, 5).attr('fill': 'red')
  leftCtrl = paper.circle(x, y + height / 2, 5).attr('fill': 'red')
  rightCtrl = paper.circle(x + width, y + height / 2, 5).attr('fill': 'red')
  addHoverListener topCtrl
  addHoverListener leftCtrl
  addHoverListener rightCtrl
  addHoverListener bottomCtrl
  return

addHoverListener = (obj) ->
  obj.mouseover (event) ->
    obj.attr 'fill': 'green'
    return
  obj.mouseout (event) ->
    obj.attr 'fill': 'red'
    return
  return

$(document).on "page:change", ->

  alert("Alou")
  console.log("xxx")
  createRect 100, 100, 100, 50
