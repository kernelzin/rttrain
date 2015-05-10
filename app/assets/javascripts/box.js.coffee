$ ->
  bx = $('#js').val()
  be = $('#editjs').val()
  ctr = undefined
  if bx == "box"

    p = $('#picture')
    x =  p.width()
    y =  p.height()

    nw = p.get(0).naturalWidth
    nh = p.get(0).naturalHeight

    ratio = nw / x
    box = []
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

    Shape = (x, y, w, h, fill, char, id, box_id) ->
      # This is a very simple and unsafe constructor. All we're doing is checking if the values exist.
      # "x || 0" just means "if there is a value for x, use that. Otherwise use 0."
      # But we aren't checking anything else! We could put "Lalala" for the value of x
      @x = x or 0
      @y = y or 0
      @w = w or 1
      @h = h or 1
      @fill = fill or '#AAAAAA'
      @selected = false
      @closeEnough = 5
      @char = char
      @id = id
      @box_id = box_id
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
      if be == "true"
        canvas.addEventListener 'selectstart', ((e) ->
          e.preventDefault()
          false
        ), false
        # Up, down, and move are for dragging
        #
        #
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
          mouse = myState.getMouse(e)
          mx = mouse.x
          my = mouse.y
          if myState.selection
            myState.selection.touchedAtHandles(mx,my, e)
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
          box_id = myState.shapes[0].box_id
          myState.addShape new Shape(mouse.x - 10, mouse.y - 10, 20, 20, 'rgba()', "", undefined , box_id )
          return
        ), true
        # mouse down handler for selected state


      mouseDownSelected = (e, shape) ->
        mouse = myState.getMouse(e)
        mouseX = mouse.x
        mouseY = mouse.y
        self = shape
        # if there isn't a rect yet
        #
        #
        #
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
          e.target.style.cursor = 'nwse-resize'
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
          e.target.style.cursor = 'nesw-resize'
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
          e.target.style.cursor = 'nesw-resize'
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
          e.target.style.cursor = 'nwse-resize'
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
      @selectionColor = 'red'
      @selectionWidth = 1
      @interval = 10
      setInterval (->
        myState.draw()
        return
      ), myState.interval
      return

    # If you dont want to use <body onLoad='init()'>
    # You could uncomment this init() reference and place the script reference inside the body tag
    #init();


    init = (s) ->
      px = p.get(0).naturalWidth / ratio
      py = p.get(0).naturalHeight / ratio

      $.getJSON window.location + ".json", (data) ->
        box_id = data.id
        for blob in data.chars
          bx = blob.x1 / ratio
          byy = py - (blob.y2 / ratio)
          bw = (blob.x2 - blob.x1) / ratio
          bh = (blob.y2 - blob.y1) / ratio
          s.addShape new Shape(bx, byy, bw, bh,'rgba(127, 255, 212, .5)', blob.char, blob.id, data.id)
      return

    # checks if two points are close enough to each other depending on the closeEnough param

    checkCloseEnough = (p1, p2, closeEnough) ->
      Math.abs(p1 - p2) < closeEnough

    Shape::draw = (ctx) ->
      ctx.beginPath();
      ctx.strokeRect @x, @y, @w, @h
      ctx.strokeStyle='green'
      ctx.lineWidth="2"
      ctx.stroke();
      ctx.fill()
      shape = this
      if @selected == true
        poster(shape)
        @drawHandles ctx
      return

    Shape::drawChars = (ctx) ->
      # ctx.fillStyle = 'rgba(0,0 ,0 , .1)';
      ctx.save()
      ctx.strokeStyle='black'
      ctx.fillStyle = 'rgba(255, 0, 0,1)'
      ctx.lineWidth="1"
      ctx.font = '27px bold,  Helvetica, sans-serif';
      ctx.textBaseline = "middle"
      tx = @x - (@w / 10)
      ty = @y + (@h /2)
      ctx.fillText(@char, tx , ty)
      ctx.strokeText(@char, tx , ty)
      ctx.restore()

    # Draw handles for resizing the Shape
    Shape::drawHandles = (ctx) ->
      @close = 5
      fill_inputs(this)
      select_row(this)
      drawRectWithBorder @x, @y, @close, ctx
      drawRectWithBorder @x + @w, @y, @close, ctx
      drawRectWithBorder @x + @w, @y + @h, @close, ctx
      drawRectWithBorder @x, @y + @h, @close, ctx
      return

    # Determine if a point is inside the shape's bounds

    Shape::contains = (mx, my) ->
      # if @touchedAtHandles(mx, my) == true
      #   return true
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

    Shape::touchedAtHandles = (mx, my, e) ->
      # 1. top left handle
      if checkCloseEnough(mx, @x, @closeEnough) and checkCloseEnough(my, @y, @closeEnough)
        if e
          e.target.style.cursor = 'nwse-resize'
        return true
      else if checkCloseEnough(mx, @x + @w, @closeEnough) and checkCloseEnough(my, @y, @closeEnough)
        if e
          e.target.style.cursor = 'nesw-resize'
        return true
      else if checkCloseEnough(mx, @x, @closeEnough) and checkCloseEnough(my, @y + @h, @closeEnough)
        if e
          e.target.style.cursor = 'nesw-resize'
        return true
      else if checkCloseEnough(mx, @x + @w, @closeEnough) and checkCloseEnough(my, @y + @h, @closeEnough)
        if e
          e.target.style.cursor = 'nwse-resize'
        return true
      return

    CanvasState::selectShape = (shape) ->
      select_shape = (shape) ->
      result =  @shapes.filter (result) ->
        return  result.id == shape
      prev = seek_selected()
      unless prev
        @selection = result[0]
        result[0].selected = true
        this.valid = false
      if result[0] != prev and prev != undefined
        prev.selected = false
        prev.valid = true

    CanvasState::addShape = (shape) ->
      @shapes.push shape
      @valid = false
      return

    CanvasState::removeShape = (shape) ->
      next = @shapes.indexOf(shape) + 1
      @shapes.splice(shape, 1)
      @valid = false

      if @shapes[next]
        @shapes[next].selected = true
        @selection = @shapes[next]

    CanvasState::nextShape = (shape) ->
      @valid = false
      shape.selected = false
      next = @shapes.indexOf(shape) + 1
      if @shapes[next]
        @shapes[next].selected = true
        @selection = @shapes[next]
      else
        @shapes[0].selected = true
        @selection = @shapes[0]

    CanvasState::changeShape = (shape) ->
      blob = @shapes.indexOf(shape)
      @shapes[blob] = shape
      @selection = @shapes[blob]
      poster(@shapes[blob])
      @valid = false

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
            shapes[i].drawChars ctx
          i++
        # draw selected shape
        if @selection != null
          if this.selection.draw
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
      ctx.strokeStyle = 'red'
      ctx.fillStyle = '#000000'
      ctx.lineWidth="2"
      ctx.fillRect x - sideLength / 2, y - sideLength / 2, sideLength, sideLength
      ctx.fillStyle = '#FFFFFF'
      ctx.fillRect x - (sideLength - 1) / 2, y - (sideLength - 1) / 2, sideLength - 1, sideLength - 1
      ctx.stroke()
      ctx.restore()
      return

    seek_selected = ->
      for b in s.shapes
        if b
          if b.selected
            return b

    select_row = (char) ->
      $('.table > tbody > tr').each ->
        tbody =  $('.table > tbody')

        if char.id == $(this).context.children[1].textContent
          clear_tab()
          $(this).attr("class", "active");
          tbody.scrollTop(0)
          tbody.scrollTop($(this).position().top)

    fill_inputs = (blob) ->
      $('#sx').val(parseInt(blob.x))
      $('#sy').val(parseInt(blob.y))
      $('#sw').val(parseInt(blob.w))
      $('#sh').val(parseInt(blob.h))
      $('#sc').val(blob.char)
      $('#sc').focus()
      $('#sc').select()

    detect_input =(field) ->
      blob = seek_selected()
      input = $(field).val()
      id = $(field).get(0).id
      switch id
        when "sc" then(
          if blob
            if blob.char != input
              if input != ''
                blob.char = input
                s.changeShape(blob)
            else
              s.nextShape(blob)

          )
        when "sx" then(
          if input > 0
            if blob
              blob.x = parseInt(input)
              s.changeShape(blob)
          )
        when "sy" then(
          if input > 0
            if blob
              blob.y = parseInt(input)
              s.changeShape(blob)
          )
        when "sh" then(
          if input > 0
            if blob
              blob.h = parseInt(input)
              s.changeShape(blob)
          )
        when "sw" then(
          if input > 0
            if blob
              blob.w = parseInt(input)
              s.changeShape(blob)
          )

    s = new CanvasState($('#canvas').get(0))
    init(s)


    $('#sc').change ->
      detect_input(@)

    $('#sx').change ->
      detect_input(@)

    $('#sy').change ->
      detect_input(@)

    $('#sw').change ->
      detect_input(@)

    $('#sh').change ->
      detect_input(@)

    $('#sc').bind 'keyup', (e) ->
      shape = seek_selected()
      sx = parseInt(shape.x)
      sy = parseInt(shape.y)
      sw = parseInt(shape.w)
      sh = parseInt(shape.h)
      e.preventDefault

      switch
        when e.keyCode == 38 && e.ctrlKey  then(
          shape.h = sh + 1
          s.changeShape(shape)
        )
        when e.ctrlKey &&  e.which == 40 then (
          shape.h = sh - 1
          s.changeShape(shape)
        )
        when e.ctrlKey &&  e.which == 37 then (
          shape.w = sw - 1
          s.changeShape(shape)
        )
        when e.ctrlKey &&  e.which == 39 then (
          shape.w = sw + 1
          s.changeShape(shape)
        )
        when e.keyCode == 13  then(
          s.nextShape(shape)
        )
        when e.keyCode == 38 && !e.ctrlKey  then(
          shape.y = sy - 1
          s.changeShape(shape)
        )
        when e.keyCode == 40 && !e.ctrlKey then(
          shape.y = sy + 1
          s.changeShape(shape)
        )
        when e.keyCode == 39 && !e.ctrlKey then(
          e.preventDefault
          shape.x = sx + 1
          s.changeShape(shape)
        )
        when e.keyCode == 37 && !e.ctrlKey then(
          e.preventDefault
          shape.x = sx - 1
          s.changeShape(shape)
        )

    $(document).bind 'keyup', (e) ->
      if e.keyCode == 46
        if ctr
          ctr.remove()
        sel = seek_selected()
        eraser(sel)
        s.removeShape(s.shapes.indexOf(sel))

    $('#nav').affix offset:
      top: $('#nav').offset().top
      bottom: $('footer').outerHeight(true) + $('.application').outerHeight(true) + 40


    poster = (shape) ->
      partial = toJs(shape)
          # post = $.post('/boxes.json', partial, response, "json")
      post = $.ajax
        type: 'POST'
        url: '/boxes.json'
        data: partial
        success: (data) ->
          shape.id = data.id
        dataType: "json"


    eraser = (shape) ->
      l = window.location.href
      ll = l.substring(0, l.length - 5) + ".json"
      partial = toJs(shape)
      post = $.ajax
        type: 'DELETE'
        url: ll
        data: partial
        success: ->

        dataType: "json"


    toJs = (obj) ->
      jsonText = {"chars" : {"char": obj.char, "x" : obj.x * ratio , "y" : nh - (obj.y * ratio) , "w": obj.w * ratio  ,"h" : obj.h * ratio , "id" : obj.id, "box" : obj.box_id}}
      return jsonText

    clear_tab = ->
      $('.table > tbody > tr').each ->
        $(this).attr 'class', ''
        return

    $('.table > tbody > tr').click ->
      $(this).preventDefault
      clear_tab()
      td = $(this).closest()

      s.selectShape(td.context.children[1].textContent)
      $(this).attr("class", "active");
      $(this).attr("class", "current");
    return
