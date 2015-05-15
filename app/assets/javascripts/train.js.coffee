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

previewImage = ->
  imgDiv = pictureCount()

  # console.log(imgDiv.inpId)
  # console.log(imgDiv.imgO)
  # console.log(imgDiv.pic)

  readURL = (input) ->
    console.log($(input).parent().next().attr("src"))
    if input.files and input.files[0]
      reader = new FileReader
      console.log(reader)
      reader.onload = (e) ->
        $(input).parent().next().attr 'src', e.target.result
        return

      reader.readAsDataURL input.files[0]
    return

  $('.fileIn').change ->
    readURL this

    return


$(this).ready(previewImage)
$(this).on('cocoon:after-insert', previewImage)
