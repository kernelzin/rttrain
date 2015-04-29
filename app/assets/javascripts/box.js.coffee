# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



#
# rect with line handlers


$ ->
  x =  $('#note_photo').width()
  y =  $('#note_photo').height()
  console.log(x)
  console.log(y)
  # $('#note_photo').after('<canvas>')
  # $('#note_photo').next().attr("id","threshold");



  c = $('#threshold')
  cp = $('#threshold').get(0).getContext('2d');

  c.width(x)
  c.height(y)

  console.log(c)

  img = $('#note_photo').get(0)

  cp.drawImage(img, 0, 0, 2167, 2042)
  pixel = cp.getImageData(0,0, c.width(), c.height())


  console.log(pixel)

  console.log(img)
  console.log(img.width)
  console.log(img.height)

  console.log(c.width())
  console.log(c.height())

  threshold = (pixel, threshold) ->
    d = pixel.data
    i = 0
    while i < d.length
      r = d[i]
      g = d[i + 1]
      b = d[i + 2]
      v = if 0.2126 * r + 0.7152 * g + 0.0722 * b >= threshold then 255 else 0
      d[i] = d[i + 1] = d[i + 2] = v
      i += 4
    cp = $('#threshold').get(0).getContext('2d');
    pixel
    cp.putImageData(pixel, 0, 0);
    console.log(pixel)

  # threshold(pixel, 100)



#   console.log("xxx")

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
