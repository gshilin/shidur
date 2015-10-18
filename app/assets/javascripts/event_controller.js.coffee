# Event Controller for Question Receiver

$ ->
  window.chat = new Chat($('#chat').data('uri'))

class window.Chat
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
    @content = $('.sidebar-question .content')
    @message = $('#message')

    @localhost = "http://" + url
    @wsURL = "ws://" + url + "/ws"
    return if @localhost == "http://undefined"

    @connectWS()

    @bindEvents()

    @endAudio = new Audio('/music/ding.mp3');
    @endAudio.setAttribute('preload', 'true');

  connectWS: =>
    console?.log "Connecting...."
    @dispatcher = new ReconnectingWebSocket(@wsURL, null, {reconnectInterval: 3000, reconnectDecay: 1})

  disconnectClient: =>
    alert 'disconnect'

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
      @appendMessages payload

    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    $('.show-question').on 'click', @showQuestion
    $('.switch-slides-question').on 'click', @switchSlidesQuestion
    $('.clear-all').on 'click', @clearQuestions

  clearQuestions: =>
    $.ajax
      url: @localhost + "/messages"
      type: "post"
      dataType: "json"
      data:
        _method: 'delete'
      success: =>
        $('.sidebar-question .content').html("")
        $('#chat').html("")
      error: (response, status, error) ->
        console.log("Delete messages:", status, "; Error:", error)

  loadMessages: =>
    return if @localhost == "http://undefined"

    $.ajax
      url: @localhost + "/messages"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        console?.log(data)
        for message in data.messages
          @appendMessage message
        lastQuestion = data.last_question
        $('.sidebar-question .content').html(lastQuestion.message) unless lastQuestion.ID == 0
      error: (response, status, error) ->
        console.log("List Messages:", status, "; Error:", error)

  showQuestion: (event) =>
    content = $('.sidebar-question .content').html()
    big_window.displayLiveQuestion(content)
    $('.show-question').removeClass('btn-success').addClass('btn-default')
    false

  switchSlidesQuestion: (event) =>
    event.stopPropagation()
    event.stopImmediatePropagation()
    big_window.switchSlidesQuestion()
    false

  sendMessage: (event) =>
    event.preventDefault()
    message = @message.val()
    @dispatcher.send JSON.stringify {user_name: 'נתב', message: message, type: 'message'}
    @message.val('')

  appendMessages: (payload) =>
    message = JSON.parse payload.data
    console?.log "Message: ", message
    if message.type == 'question'
      messageTemplate = @template_question(message)
      @checkNewQuestion message
    else
      messageTemplate = @template_message(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140

  appendMessage: (message) =>
    if message.type == 'question'
      messageTemplate = @template_question(message)
      @checkNewQuestion message
    else
      messageTemplate = @template_message(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140

  checkNewQuestion: (message) =>
    data = message.message
    old_data = @content.html()
    if (data != old_data)
      @content.html(data)
      $('.show-question').removeClass('btn-default').addClass('btn-success')
      @endAudio.play()
