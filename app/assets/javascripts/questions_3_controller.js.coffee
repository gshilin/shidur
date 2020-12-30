# Event Controller for Three Questions Receiver

$ ->
  url = window.location.hostname # + ":4000"
  window.q3 = new Q3(url)

class window.Q3

  dispatcher: null

  constructor: (url) ->
    @localhost = "https://" + url + "/ws"
    @wsURL     = "wss://" + url + "/ws/ws"
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

  loadQuestions: =>
    return if @localhost == "http://undefined"

    $.ajax
      url: @localhost + "/congress"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        console?.log("Got data:", data)
        for question in data.questions
          if question.ID == 0 || question.id == 0
            $('.text-' + question.language).html('')
          else
            $('.text-' + question.language).html(question.message)
      error: (response, status, error) ->
        console?.log("List Messages:", status, "; Error:", error)

  replaceMessage: (payload) =>
    message = JSON.parse payload.data
    console.log(message)
    if message.length == 0
      $('.text').html('')
      return
    # single language question
    if message.type == 'question' and message.approved == true
      $('.text-' + message.language).html(message.message)
    # clear message -- array of empty questions
    if Array.isArray(message.questions)
      $('span.text').val (idx, val) =>
          $($('span.text')[idx]).html("")
