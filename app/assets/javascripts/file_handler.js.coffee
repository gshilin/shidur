class window.FileHandler
  dropZone = null

  constructor: (id) ->
    # Setup the dnd listeners.
    @dropZone = $(id)
    if (@dropZone != null)
      @dropZone.on 'dragenter', @handleDragEnter
      @dropZone.on 'dragleave', @handleDragLeave
      @dropZone.on 'dragover', @handleDragOver
      @dropZone.on 'drop', @handleFileSelect

  handleFileSelect: (evt) =>
    evt.stopPropagation()
    evt.preventDefault()
    @dropZone.removeClass 'over'

    file = evt.originalEvent.dataTransfer.files[0]
    reader = new FileReader()

    # Closure to capture the file information.
    reader.onload = ((theFile) ->
      (e) ->
        result = e.target.result
        lines = result.split(/\n|\r\n/)
        author = lines[0].split(RegExp(' +')).splice(1).join(' ')
        title = lines[1].split(RegExp(' +')).splice(1).join(' ')

        $('#book_author').val(author)
        $('#book_title').val(title)
        $('#book_content').val(result)
    )(file)

    # Read in the image file as a data URL.
    reader.readAsText file

  handleDragOver: (evt) =>
    evt.stopPropagation()
    evt.preventDefault()
    # Explicitly show this is a copy.
    evt.originalEvent.dataTransfer.dropEffect = 'copy'

  handleDragEnter: (evt) =>
    @dropZone.addClass 'over'

  handleDragLeave: (evt) =>
    @dropZone.removeClass 'over'
