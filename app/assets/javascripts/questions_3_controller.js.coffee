# Event Controller for Three Questions Receiver

class window.Q3

  dispatcher: null

  constructor: (url) ->

    @localhost = "http://" + url
    @wsURL = "ws://" + url + "/ws"
    return if @localhost == "http://undefined"

    @connectWS()

    @bindEvents()

  connectWS: =>
    console?.log "Connecting...."
    @dispatcher = new ReconnectingWebSocket(@wsURL, null, {reconnectInterval: 3000, reconnectDecay: 1})

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.onopen = =>
      console?.log "Connected"
      $('.led').removeClass('led-red').addClass('led-green')
      @loadQuestions()
    @dispatcher.onerror = ->
      console?.log "Connection Error"
      $('.led').removeClass('led-green').addClass('led-red')
    @dispatcher.onclose = ->
      console?.log "Disconnected"
      $('.led').removeClass('led-green').addClass('led-red')

    @dispatcher.onmessage = (payload) =>
      @replaceMessage payload

  loadQuestions: =>
    return if @localhost == "http://undefined"

    $.ajax
      url: @localhost + "/3questions"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        console?.log(data)
        for question in data.questions
          if question.ID == 0
            $('.text-' + question.language).html('')
          else
            $('.text-' + question.language).html(question.message)
      error: (response, status, error) ->
        console.log("List Messages:", status, "; Error:", error)

  replaceMessage: (payload) =>
    message = JSON.parse payload.data
    if message.length == 0
      $('.text').html('')
      return
    console?.log "Message: ", message
    if message.type == 'question' and message.approved == true
      $('.text-' + message.language).html(message.message)
