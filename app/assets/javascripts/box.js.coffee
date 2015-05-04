$ ->

  p = $('#picture')
  x =  p.width()
  y =  p.height()

  # b = $('#canvas')
  # b.width(x)
  # b.height(y)
  box = []
  # canvas = (c) ->
  #   img = $('#picture').get(0)
  #   cp = b.get(0).getContext('2d')
  #   cp.canvas.width = img.naturalWidth
  #   cp.canvas.height = img.naturalHeight
  #   cp.drawImage(img, 0, 0)
  #   pixel = cp.getImageData(0,0, img.width, img.height)
  #   cp

  # canvas()


  blob = (c) ->
    cp = $('#canvas').get(0).getContext('2d')
    # cp.beginPath()
    cp.strokeRect(c.x1, p - c.y2 , c.x2 - c.x1, c.y2 - c.y1)
    # cp.fillStyle = 'yellow'
    # cp.fill()
    cp.lineWidth = 3
    cp.strokeStyle = 'red'
    cp.stroke()



    # Draws this shape to a given context
  # By Simon Sarris
  # www.simonsarris.com
  # sarris@acm.org
  #
  # Last update December 2011
  #
  # Free to use and distribute at will
  # So long as you are nice to people, etc
  # Constructor for Shape objects to hold data for all drawn objects.
  # For now they will just be defined as rectangles.

  # Draws this shape to a given context
# By Simon Sarris
# www.simonsarris.com
#
# Extended by Philipp Sporrer
# planifica.meteor.com
#
# Last update December 2014
#
# Free to use and distribute at will
# So long as you are nice to people, etc
# Constructor for Shape objects to hold data for all drawn objects.
# For now they will just be defined as rectangles.

  Shape = (x, y, w, h, fill) ->
    # This is a very simple and unsafe constructor. All we're doing is checking if the values exist.
    # "x || 0" just means "if there is a value for x, use that. Otherwise use 0."
    # But we aren't checking anything else! We could put "Lalala" for the value of x
    @x = x or 0
    @y = y or 0
    @w = w or 1
    @h = h or 1
    @fill = fill or '#AAAAAA'
    @selected = false
    @closeEnough = 10
    return

  CanvasState = (canvas) ->
    # **** First some setup! ****
    @canvas = canvas
    @width = x
    @height = y
    @ctx = canvas.getContext('2d')
    # This complicates things a little but but fixes mouse co-ordinate problems
    # when there's a border or padding. See getMouse for more detail
    stylePaddingLeft = undefined
    stylePaddingTop = undefined
    styleBorderLeft = undefined
    styleBorderTop = undefined
    if document.defaultView and document.defaultView.getComputedStyle
      @stylePaddingLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingLeft'], 10) or 0
      @stylePaddingTop = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingTop'], 10) or 0
      @styleBorderLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderLeftWidth'], 10) or 0
      @styleBorderTop = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderTopWidth'], 10) or 0
    # Some pages have fixed-position bars (like the stumbleupon bar) at the top or left of the page
    # They will mess up mouse coordinates and this fixes that
    html = document.body.parentNode
    @htmlTop = html.offsetTop
    @htmlLeft = html.offsetLeft
    # **** Keep track of state! ****
    @valid = false
    # when set to false, the canvas will redraw everything
    @shapes = box
    # the collection of things to be drawn
    @dragging = false
    # Keep track of when we are dragging
    # the current selected object. In the future we could turn this into an array for multiple selection
    @selection = null
    @dragoffx = 0
    # See mousedown and mousemove events for explanation
    @dragoffy = 0
    # **** Then events! ****
    # This is an example of a closure!
    # Right here "this" means the CanvasState. But we are making events on the Canvas itself,
    # and when the events are fired on the canvas the variable "this" is going to mean the canvas!
    # Since we still want to use this particular CanvasState in the events we have to save a reference to it.
    # This is our reference!
    myState = this
    #fixes a problem where double clicking causes text to get selected on the canvas
    canvas.addEventListener 'selectstart', ((e) ->
      e.preventDefault()
      false
    ), false
    # Up, down, and move are for dragging
    canvas.addEventListener 'mousedown', ((e) ->
      mouse = myState.getMouse(e)
      mx = mouse.x
      my = mouse.y
      shapes = myState.shapes
      l = shapes.length
      # tmp var if one gets selected
      tmpSelected = false
      i = l - 1
      while i >= 0
        mySel = shapes[i]
        if shapes[i].contains(mx, my) and tmpSelected == false
          # check if this shape is already selected
          if myState.selection == mySel
            if shapes[i].touchedAtHandles(mx, my)
              # in this case the shape is touched at the handles -> resize
              # pass event to shape event handler and begin possible resizing
              mouseDownSelected e, mySel
              myState.resizing = true
            else
              # in this case the shape is touched, but NOT at the handles -> drag
              # Keep track of where in the object we clicked
              # so we can move it smoothly (see mousemove)
              myState.dragoffx = mx - mySel.x
              myState.dragoffy = my - mySel.y
              myState.dragging = true
          myState.selection = mySel
          # set the state of the shape as selected
          mySel.selected = true
          myState.valid = false
          tmpSelected = true
          # return;
        else
          # unset the state of the shape as selected
          mySel.selected = false
          myState.valid = false
        i--
      # if no shape was touched
      if tmpSelected == false
        myState.selection = null
      # havent returned means we have failed to select anything.
      # If there was an object selected, we deselect it
      # if (myState.selection) {
      #   myState.selection = null;
      #   myState.valid = false; // Need to clear the old selection border
      # }
      return
    ), true
    canvas.addEventListener 'mousemove', ((e) ->
      @style.cursor = 'auto'
      if myState.dragging
        mouse = myState.getMouse(e)
        # We don't want to drag the object by its top-left corner, we want to drag it
        # from where we clicked. Thats why we saved the offset and use it here
        myState.selection.x = mouse.x - myState.dragoffx
        myState.selection.y = mouse.y - myState.dragoffy
        myState.valid = false
        # Something's dragging so we must redraw
      if myState.resizing
        mouseMoveSelected e, myState.selection
      return
    ), true
    canvas.addEventListener 'mouseup', ((e) ->
      myState.dragging = false
      myState.resizing = false
      mouseUpSelected e
      return
    ), true
    # double click for making new shapes
    canvas.addEventListener 'dblclick', ((e) ->
      mouse = myState.getMouse(e)
      r = Math.floor(Math.random() * 255)
      g = Math.floor(Math.random() * 255)
      b = Math.floor(Math.random() * 255)
      myState.addShape new Shape(mouse.x - 10, mouse.y - 10, 20, 20, 'rgba(' + r + ',' + g + ',' + b + ',.6)')
      return
    ), true
    # mouse down handler for selected state

    mouseDownSelected = (e, shape) ->
      mouse = myState.getMouse(e)
      mouseX = mouse.x
      mouseY = mouse.y
      self = shape
      # if there isn't a rect yet
      if self.w == undefined
        self.x = mouseY
        self.y = mouseX
        myState.dragBR = true
      else if checkCloseEnough(mouseX, self.x, self.closeEnough) and checkCloseEnough(mouseY, self.y, self.closeEnough)
        myState.dragTL = true
        e.target.style.cursor = 'nw-resize'
      else if checkCloseEnough(mouseX, self.x + self.w, self.closeEnough) and checkCloseEnough(mouseY, self.y, self.closeEnough)
        myState.dragTR = true
        e.target.style.cursor = 'ne-resize'
      else if checkCloseEnough(mouseX, self.x, self.closeEnough) and checkCloseEnough(mouseY, self.y + self.h, self.closeEnough)
        myState.dragBL = true
        e.target.style.cursor = 'sw-resize'
      else if checkCloseEnough(mouseX, self.x + self.w, self.closeEnough) and checkCloseEnough(mouseY, self.y + self.h, self.closeEnough)
        myState.dragBR = true
        e.target.style.cursor = 'se-resize'
      else
        # handle not resizing
      myState.valid = false
      # something is resizing so we need to redraw
      return

    mouseUpSelected = (e) ->
      myState.dragTL = myState.dragTR = myState.dragBL = myState.dragBR = false
      return

    mouseMoveSelected = (e, shape) ->
      mouse = myState.getMouse(e)
      mouseX = mouse.x
      mouseY = mouse.y
      if myState.dragTL
        e.target.style.cursor = 'nw-resize'
        # switch to top right handle
        if shape.x + shape.w - mouseX < 0
          myState.dragTL = false
          myState.dragTR = true
        # switch to top bottom left
        if shape.y + shape.h - mouseY < 0
          myState.dragTL = false
          myState.dragBL = true
        shape.w += shape.x - mouseX
        shape.h += shape.y - mouseY
        shape.x = mouseX
        shape.y = mouseY
      else if myState.dragTR
        e.target.style.cursor = 'ne-resize'
        # switch to top left handle
        if shape.x - mouseX > 0
          myState.dragTR = false
          myState.dragTL = true
        # switch to bottom right handle
        if shape.y + shape.h - mouseY < 0
          myState.dragTR = false
          myState.dragBR = true
        shape.w = Math.abs(shape.x - mouseX)
        shape.h += shape.y - mouseY
        shape.y = mouseY
      else if myState.dragBL
        e.target.style.cursor = 'sw-resize'
        # switch to bottom right handle
        if shape.x + shape.w - mouseX < 0
          myState.dragBL = false
          myState.dragBR = true
        # switch to top left handle
        if shape.y - mouseY > 0
          myState.dragBL = false
          myState.dragTL = true
        shape.w += shape.x - mouseX
        shape.h = Math.abs(shape.y - mouseY)
        shape.x = mouseX
      else if myState.dragBR
        e.target.style.cursor = 'se-resize'
        # switch to bottom left handle
        if shape.x - mouseX > 0
          myState.dragBR = false
          myState.dragBL = true
        # switch to top right handle
        if shape.y - mouseY > 0
          myState.dragBR = false
          myState.dragTR = true
        shape.w = Math.abs(shape.x - mouseX)
        shape.h = Math.abs(shape.y - mouseY)
      myState.valid = false
      # something is resizing so we need to redraw
      return

    # **** Options! ****
    @selectionColor = '#000000'
    @selectionWidth = 0.5
    @interval = 30
    setInterval (->
      myState.draw()
      return
    ), myState.interval
    return

  # If you dont want to use <body onLoad='init()'>
  # You could uncomment this init() reference and place the script reference inside the body tag
  #init();

  init = ->
    s = new CanvasState($('#canvas').get(0))
    px = p.get(0).naturalWidth / 2.5
    py = p.get(0).naturalHeight / 2.5

    s.addShape new Shape(221, py - 847.2 , 14.4, 26.4, 'rgba(127, 255, 212, .5)')
    # $.getJSON window.location + ".json", (data) ->
    #   for blob in data.chars
    #     bx = blob.x1 / 2.5
    #     byy = py - (blob.y2 / 2.5)
    #     bw = (blob.x2 - blob.x1) / 2.5
    #     bh = (blob.y2 - blob.y1) / 2.5
    #     s.addShape new Shape(bx, byy, bw, bh,'rgba(127, 255, 212, .5)')

    #     # c.x1, p - c.y2 , c.x2 - c.x1, c.y2 - c.y1
    #     console.log(blob)
    #     s.addShape new Shape(blob.x1, p - blob.y2, blob.x2 - blob.x1, blob.y2 - blob.y1)
    #     # # The default is gray
    #     # s.addShape new Shape(60, 140, 40, 60, 'lightskyblue')
    #     # # Lets make some partially transparent
    #     # s.addShape new Shape(80, 150, 60, 30, 'rgba(127, 255, 212, .5)')
    #     # s.addShape new Shape(125, 80, 30, 80, 'rgba(245, 222, 179, .7)')
    # console.log(s.addShape)
    return

  # checks if two points are close enough to each other depending on the closeEnough param

  checkCloseEnough = (p1, p2, closeEnough) ->
    Math.abs(p1 - p2) < closeEnough

  Shape::draw = (ctx) ->
    ctx.fillStyle = @fill
    ctx.fillRect @x, @y, @w, @h
    if @selected == true
      @drawHandles ctx
    return

  # Draw handles for resizing the Shape

  Shape::drawHandles = (ctx) ->
    drawRectWithBorder @x, @y, @closeEnough, ctx
    drawRectWithBorder @x + @w, @y, @closeEnough, ctx
    drawRectWithBorder @x + @w, @y + @h, @closeEnough, ctx
    drawRectWithBorder @x, @y + @h, @closeEnough, ctx
    return

  # Determine if a point is inside the shape's bounds

  Shape::contains = (mx, my) ->
    if @touchedAtHandles(mx, my) == true
      return true
    xBool = false
    yBool = false
    # All we have to do is make sure the Mouse X,Y fall in the area between
    # the shape's X and (X + Width) and its Y and (Y + Height)
    if @w >= 0
      xBool = @x <= mx and @x + @w >= mx
    else
      xBool = @x >= mx and @x + @w <= mx
    if @h >= 0
      yBool = @y <= my and @y + @h >= my
    else
      yBool = @y >= my and @y + @h <= my
    xBool and yBool

  # Determine if a point is inside the shape's handles

  Shape::touchedAtHandles = (mx, my) ->
    # 1. top left handle
    if checkCloseEnough(mx, @x, @closeEnough) and checkCloseEnough(my, @y, @closeEnough)
      return true
    else if checkCloseEnough(mx, @x + @w, @closeEnough) and checkCloseEnough(my, @y, @closeEnough)
      return true
    else if checkCloseEnough(mx, @x, @closeEnough) and checkCloseEnough(my, @y + @h, @closeEnough)
      return true
    else if checkCloseEnough(mx, @x + @w, @closeEnough) and checkCloseEnough(my, @y + @h, @closeEnough)
      return true
    return

  CanvasState::addShape = (shape) ->
    @shapes.push shape
    @valid = false
    return

  CanvasState::clear = ->
    @ctx.clearRect 0, 0, @width, @height
    return

  # While draw is called as often as the INTERVAL variable demands,
  # It only ever does something if the canvas gets invalidated by our code

  CanvasState::draw = ->
    # if our state is invalid, redraw and validate!
    if !@valid
      ctx = @ctx
      shapes = @shapes
      @clear()
      img = $('#picture').get(0)

      ctx.canvas.width = x
      ctx.canvas.height = y

      # console.log(img.width)
      # console.log(img.height)

      # console.log(ctx.canvas.width)
      # console.log(ctx.canvas.height)

      ctx.drawImage(img, 0, 0, x, y  )

      # ** Add stuff you want drawn in the background all the time here **
      # draw all shapes
      l = shapes.length
      i = 0
      while i < l
        shape = shapes[i]
        if @selection != shape
          # draw this shape as last
          # We can skip the drawing of elements that have moved off the screen:
          if shape.x > @width or shape.y > @height or shape.x + shape.w < 0 or shape.y + shape.h < 0
            i++
            continue
          shapes[i].draw ctx
        i++
      # draw selected shape
      if @selection != null
        @selection.draw ctx
      # draw selection
      # right now this is just a stroke along the edge of the selected Shape
      if @selection != null
        ctx.strokeStyle = @selectionColor
        ctx.lineWidth = @selectionWidth
        mySel = @selection
        ctx.strokeRect mySel.x, mySel.y, mySel.w, mySel.h
      # ** Add stuff you want drawn on top all the time here **
      @valid = true
    return

  # Creates an object with x and y defined, set to the mouse position relative to the state's canvas
  # If you wanna be super-correct this can be tricky, we have to worry about padding and borders

  CanvasState::getMouse = (e) ->
    element = @canvas
    offsetX = 0
    offsetY = 0
    mx = undefined
    my = undefined
    # Compute the total offset
    if element.offsetParent != undefined
      loop
        offsetX += element.offsetLeft
        offsetY += element.offsetTop
        unless element = element.offsetParent
          break
    # Add padding and border style widths to offset
    # Also add the <html> offsets in case there's a position:fixed bar
    offsetX += @stylePaddingLeft + @styleBorderLeft + @htmlLeft
    offsetY += @stylePaddingTop + @styleBorderTop + @htmlTop
    mx = e.pageX - offsetX
    my = e.pageY - offsetY
    # We return a simple javascript object (a hash) with x and y defined
    {
      x: mx
      y: my
    }

  # Draws a white rectangle with a black border around it

  drawRectWithBorder = (x, y, sideLength, ctx) ->
    ctx.save()
    ctx.fillStyle = '#000000'
    ctx.fillRect x - sideLength / 2, y - sideLength / 2, sideLength, sideLength
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect x - (sideLength - 1) / 2, y - (sideLength - 1) / 2, sideLength - 1, sideLength - 1
    ctx.restore()
    return

  # ---
  # generated by js2coffee 2.0.3


  init()
  setInterval(console.log(box[0].x), 100)
