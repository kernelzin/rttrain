$ ->
  console.log("train")

previewImage = ->
  readURL = (input) ->
    if input.files and input.files[0]
      reader = new FileReader
      console.log(reader)
      reader.onload = (e) ->
        $('#blah').attr 'src', e.target.result
        return

      reader.readAsDataURL input.files[0]
    return

  $('#imgInp').change ->
    console.log($('#blah'))
    console.log($('#imgInp'))
    readURL this
    return


$(this).ready(previewImage)
$(this).on('cocoon:after-insert', previewImage)
