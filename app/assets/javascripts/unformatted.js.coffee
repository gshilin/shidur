class window.Unformatted
  dropZone = null

  constructor: (id) ->
# Setup the dnd listeners.
    @dropZone = $(id)
    if (@dropZone != null)
      @dropZone.on 'dragenter', @handleDragEnter
      @dropZone.on 'dragleave', @handleDragLeave
      @dropZone.on 'dragover', @handleDragOver
      @dropZone.on 'drop', @handleFileSelect

  is_header: (node) =>
    parser = new DOMParser()
    xmlDoc = parser.parseFromString(node.innerHTML, 'text/html')
    f = document.evaluate('//strong', xmlDoc, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null)
    f.singleNodeValue

  formatWord: (text) =>
    text_block = '%author קטעים לקריאה\n%book קטעים לקריאה\n'
    letter = 1

    parser = new DOMParser()
    xmlDoc = parser.parseFromString(text, 'text/html')
    iterator = document.evaluate('//p', xmlDoc, null, XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null)
    node = iterator.iterateNext()

    while node
      if @is_header(node)
        text_block += "%H " + node.textContent + "\n"
      else
        words = node.textContent.split(' ')
        $('.test_window').text("")
        if node.textContent.match /^\d+/
          text_block += "%letter " + letter + "\n"
          letter += 1
        else
          text_block += "%break\n"

        words.forEach (word) ->
          $('.test_window').append(word + " ")
          if $('.test_window').height() < 190
            text_block += word + " "
          else
            $('.test_window').text(word + " ")
            if node.textContent.match /^\d+/
              text_block += "\n%break\n" + word + " "
            else
              text_block += "\n%break\n" + word + " "
        if $('.test_window').text().length > 0
          text_block += "\n"

      node = iterator.iterateNext()

    $('#book_author').val("קטעים לקריאה")
    $('#book_title').val('קטעים לקריאה')
    $('#book_content').val(text_block + "\n")

  handleFileSelect: (event) =>
    event.stopPropagation()
    event.preventDefault()
    @dropZone.removeClass 'over'

    @readFileInputEventAsArrayBuffer event, (arrayBuffer) =>
      mammoth.convertToHtml arrayBuffer: arrayBuffer
      .then (result) =>
        text = result.value
        messages = result.messages
        console.log messages if messages.length > 0
        @formatWord text
      .done()

  readFileInputEventAsArrayBuffer: (event, callback) =>
    file = event.originalEvent.dataTransfer.files[0]
    reader = new FileReader()

    # Closure to capture the file information.
    reader.onload = (loadEvent) ->
      arrayBuffer = loadEvent.target.result
      callback arrayBuffer

    # Read in the image file as a data URL.
    reader.readAsArrayBuffer file

  handleDragOver: (evt) =>
    evt.stopPropagation()
    evt.preventDefault()
    # Explicitly show this is a copy.
    evt.originalEvent.dataTransfer.dropEffect = 'copy'

  handleDragEnter: (evt) =>
    @dropZone.addClass 'over'

  handleDragLeave: (evt) =>
    @dropZone.removeClass 'over'
