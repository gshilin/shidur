# Event Controller for Congress Receiver

class window.Congress

  dispatcher: null

  slideIndex: 1
  slides: []
  lastTimeout: undefined

  constructor: (url) ->
    @localhost = "http://" + url
    @wsURL     = "ws://" + url + "/ws"
    return if @localhost == "http://undefined"

    @connectWS()

    @bindEvents()

  connectWS: =>
    console?.log "Connecting...."
    @dispatcher = new ReconnectingWebSocket(@wsURL, null, { reconnectInterval: 3000, reconnectDecay: 1 })

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.onopen  = =>
      console?.log "Connected"
      @loadQuestions()
    @dispatcher.onerror = ->
      console?.log "Connection Error"
    @dispatcher.onclose = ->
      console?.log "Disconnected"

    @dispatcher.onmessage = (payload) =>
      @replaceMessage payload

  carousel: =>
    if @slides[@slideIndex - 1]
      @slides[@slideIndex - 1].css('display', 'none')
    @slideIndex++
    if @slideIndex > @slides.length
      @slideIndex = 1
    if @slides[@slideIndex - 1]
      @slides[@slideIndex - 1].css('display', 'block')
    if @slides[@slideIndex - 1].text() == ""
      @carousel()
    else
      # Change image every 15 seconds
      @lastTimeout = setTimeout(@carousel, 15000)

  loadQuestions: =>
    return if @localhost == "http://undefined"

    $.ajax
      url: @localhost + "/congress"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        console?.log(data)
        for question in data.questions
          if question.ID == 0
            $('.question-' + question.language).html('')
          else
            q = $('.question-' + question.language)
            if q.length == 1
              q.html(question.message)
              @slides.push(q)
        if @slides.length > 0 and @lastTimeout == undefined
          @carousel()

      error: (response, status, error) ->
        console.log("List Messages:", status, "; Error:", error)

  replaceMessage: (payload) =>
    question = JSON.parse payload.data
    console?.log "Message: ", question
    reduce_callback = (acc, y) ->
      acc += y.id
      acc

    if Array.isArray(question?.questions)
      ids = question.questions.reduce reduce_callback, 0
      return if ids != 0 # we don't support messages, only "clear questions"

      # Clear all in case of array of empty questions
      window.clearTimeout(@lastTimeout) if @lastTimeout
      @slides = []
      for e in ['en', 'ru', 'he', 'es', 'cg']
        $('.question-' + e).html('').css('display', 'none')
      return

    q = $('.question-' + question.language)
    return if q.length == 0 # unknown language

    if question.type == 'question' and question.approved == true
      if q.html() != ''
        q.html(question.message)
        return
      q.html(question.message).css('display', 'block')
      @slides.push(q)

    if @slides.length > 0 and @lastTimeout == undefined
      @carousel()
