$ ->
  console.log("train")

pictureCount = ->
  # console.log($("#pictures > div" ))
  inpId = $("#pictures > div " ).find("#imgInp").attr("id")
  imgO = $("#pictures > div " ).find("#imgO").attr("id")
  l = $("#pictures > div > div").length
  pic = $("#pictures").length

  $("#pictures > div " ).each ->
    if inpId
      $(this).find("#imgInp").attr "id", inpId + l
      $(this).find("#imgO").attr "id", imgO + 1

  return {inpId: inpId, imgO: imgO, pic: pic}


showCoords = (c, div) ->
  console.log(c)
  console.log($(div).parent().next())
  # console.log($(div).offsetParent())
  $(div).offsetParent().find('#x1').attr "value", c.x
  $(div).offsetParent().find('#y1').attr "value", c.y
  $(div).offsetParent().find('#x2').attr "value", c.x2
  $(div).offsetParent().find('#y2').attr "value", c.y2
  $(div).offsetParent().find('#w').attr "value", c.w
  $(div).offsetParent().find('#h').attr "value", c.h


  # variables can be accessed here as
  # c.x
  # c.y
  # c.x2
  # c.y2
  # c.w
  # c.h
  return c


addJcrop = (div) ->
  $($(div).parent().next()).Jcrop
    onSelect: (coords) ->
      showCoords(coords, div)
    onChange:  (coords) ->
      showCoords(coords, div)

previewImage = ->
  imgDiv = pictureCount()
  readURL = (input) ->
    if input.files and input.files[0]
      reader = new FileReader
      reader.onload = (e) ->
        $(input).parent().next().attr 'src', e.target.result
        addJcrop(input)
        return


      reader.readAsDataURL input.files[0]
    return

  $('.fileIn').change ->

    readURL this
    return


$(this).ready(previewImage)
$(this).on('cocoon:after-insert', previewImage)
