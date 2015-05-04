$ ->
  pic = $('#js').val()
  console.log(pic)

  if pic

    p = $('#picture')
    x =  p.width()
    y =  p.height()

    c = $('#canvas')
    c.width(x)
    c.height(y)

    canvas = (c) ->
      img = $('#picture').get(0)
      cp = c.get(0).getContext('2d');
      cp.canvas.width = img.width
      cp.canvas.height = img.height
      cp.drawImage(img, 0, 0)
      pixel = cp.getImageData(0,0, img.width, img.height)
      pixel

    canvas(c)

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
      canvas($('#canvas'))
      cp = $('#canvas').get(0).getContext('2d');
      cp.putImageData(pixel, 0, 0);

    val = $('#threshold_val').val()

    threshold(canvas(c), $('#threshold').val())  if val > 0


    $('#threshold').change ->
      threshold(canvas(c), $('#threshold').val())
      $('#threshold_val').val($('#threshold').val())
      return

    $('#threshold_val').change ->
      $('#threshold').val($('#threshold_val').val())
      return

    $('#threshold_btn').click ->
      threshold(canvas(c), $('#threshold').val())
      return
    # threshold(pixel, 100)
