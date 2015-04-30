# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



#
# rect with line handlers
$ ->
  p = $('#picture')
  x =  p.width()
  y =  p.height()

  b = $('#canvas')
  b.width(x)
  b.height(y)

  canvas = (c) ->
    img = $('#picture').get(0)
    cp = b.get(0).getContext('2d')
    cp.canvas.width = img.naturalWidth
    cp.canvas.height = img.naturalHeight
    cp.drawImage(img, 0, 0)
    pixel = cp.getImageData(0,0, img.width, img.height)
    cp

  canvas()

  blob = (c) ->
    cp = canvas()
    cp.beginPath()
    cp.rect(c.x1, p - c.y2 , c.x2 - c.x1, c.y2 - c.y1)
    # cp.fillStyle = 'yellow'
    # cp.fill()
    cp.lineWidth = 3
    cp.strokeStyle = 'red'
    cp.stroke()




  $.getJSON window.location + ".json", (data) ->
    p = $('#picture').get(0).naturalHeight
    c = data.chars[0]
    for char in data.chars
      blob(char)


    # context.beginPath()
    # context.rect(188, 50, 200, 100)
    # context.fillStyle = 'yellow'
    # context.fill()
    # context.lineWidth = 7
    # context.strokeStyle = 'black'
    # context.stroke()

#   createRect = (x, y, width, height) ->
#     rect = paper.rect(x, y, width, height).attr(
#       'fill': 'white'
#       'stroke': 'red')
#     topCtrl = paper.circle(x + width / 2, y, 5).attr('fill': 'red')
#     bottomCtrl = paper.circle(x + width / 2, y + height, 5).attr('fill': 'red')
#     leftCtrl = paper.circle(x, y + height / 2, 5).attr('fill': 'red')
#     rightCtrl = paper.circle(x + width, y + height / 2, 5).attr('fill': 'red')
#     addHoverListener topCtrl
#     addHoverListener leftCtrl
#     addHoverListener rightCtrl
#     addHoverListener bottomCtrl
#     return

#   addHoverListener = (obj) ->
#     obj.mouseover (event) ->
#       obj.attr 'fill': 'green'
#       return
#     obj.mouseout (event) ->
#       obj.attr 'fill': 'red'
#       return
#     return

#   paper = new Raphael(0, 0, 500, 500)
#   # createRect 100, 100, 100, 50
