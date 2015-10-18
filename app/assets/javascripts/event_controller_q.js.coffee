# Event Controller for Question Author
$ ->
  window.chat = new Chat($('#chat').data('uri'))
  # adapt "question" window to screen size
  window.chat.adapt()

class window.Chat
  adapt: () ->
    screen_width = $('#chat').width()
    $field = $('#question_question')
    ratio = screen_width / $field.width()
    #console.log("ratio", ratio)
    $field.css({transform: 'scale(' + ratio + ')', 'transform-origin': 'top right'})

  template_message: (message) ->
    html =
    """
      <div class="message" >
        <label class="label label-info"
            style="direction: ltr; font-weight: normal; color: black;">
          [#{message.user_name}]
        </label>&nbsp;
        #{message.message}
      </div>
      """
    $(html)

  template_question: (message) ->
    html =
    """
      <div class="message" >
        <label class="label label-danger"
            style="direction: ltr; font-weight: normal; color: yellow;">
          [#{message.user_name}]
        </label>&nbsp;
        #{message.message}
      </div>
      """
    $(html)

  dispatcher: null

  constructor: (url) ->
    @message = $('#message')
    @question = $('#question_question')

    @localhost = "http://" + url
    @wsURL = "ws://" + url + "/ws"
    @connectWS()

    @bindEvents()

  connectWS: =>
    console?.log "Connecting...."
    @dispatcher = new ReconnectingWebSocket(@wsURL, null, {reconnectInterval: 3000, reconnectDecay: 1})

  bindEvents: =>
    @dispatcher.onopen = =>
      console?.log "Connected"
      $('.led').removeClass('led-red').addClass('led-green')
      @loadMessages()
    @dispatcher.onerror = ->
      console?.log "Connection Error"
      $('.led').removeClass('led-green').addClass('led-red')
    @dispatcher.onclose = ->
      console?.log "Disconnected"
      $('.led').removeClass('led-green').addClass('led-red')

    @dispatcher.onmessage = (payload) =>
      message = JSON.parse payload.data
      console?.log "Message: ", message
      @appendMessage message

    $('#question').on 'click', @sendQuestion
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  loadMessages: =>
    $.ajax
      url: @localhost + "/messages"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        console?.log(data)
        for message in data.messages
          @appendMessage message
        lastQuestion = data.last_question
        $('#question_question').html(lastQuestion.message) unless lastQuestion.ID == 0
      error: (response, status, error) ->
        console.log("List Messages:", status, "; Error:", error)

  sendQuestion: (event) =>
    event.preventDefault()
    message = @question.val()
    @dispatcher.send JSON.stringify {user_name: 'עורך', message: message, type: 'question'}

  sendMessage: (event) =>
    event.preventDefault()
    message = @message.val()
    @dispatcher.send JSON.stringify {user_name: 'עורך', message: message, type: 'message'}
    @message.val('')

  appendMessage: (message) =>
    if message.type == 'question'
      messageTemplate = @template_question(message)
    else
      messageTemplate = @template_message(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140
