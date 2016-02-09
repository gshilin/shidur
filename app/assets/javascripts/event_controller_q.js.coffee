# Event Controller for Question Author
$ ->
  window.chat = new Chat
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
        <label class="label label-info" style="direction: ltr; font-weight: normal; color: black; padding-left: 5px;">[#{message.user_name}]</label>
        <div style="display: inline-block;">#{message.message}</label>
      </div>
      """
    $(html)

  template_question: (message) ->
    html =
    """
      <div class="message" >
        <label class="label label-danger" style="direction: ltr; font-weight: normal; color: yellow; padding-left: 5px;">[#{message.user_name}]</label>
        <div style="display: inline-block;">#{message.message}</label>
      </div>
      """
    $(html)

  dispatcher: null

  constructor: () ->
    url = window.location.hostname + ":4000"

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
    language = $('select.selectpicker').val()
    @dispatcher.send JSON.stringify {
      user_name: @userName(language),
      message: message,
      type: 'question',
      language: language
    }

  sendMessage: (event) =>
    event.preventDefault()
    message = @message.val()
    language = $('select.selectpicker').val()
    @dispatcher.send JSON.stringify {
      user_name: @userName(language),
      message: message,
      type: 'message',
      language: language
    }
    @message.val('')

  appendMessage: (message) =>
    if message.type == 'question'
      messageTemplate = @template_question(message)
    else
      messageTemplate = @template_message(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140

  userName: (language) ->
    return switch language
      when 'he' then 'עורך'
      when 'en' then 'editor'
      when 'ru' then 'редактор'
