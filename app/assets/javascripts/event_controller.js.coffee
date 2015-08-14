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

    @dispatcher = new WebSocket(url)
    @bindEvents()

    @endAudio = new Audio('/music/ding.mp3');
    @endAudio.setAttribute('preload', 'true');

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.onopen = ->
      console?.log "Connected"
    @dispatcher.onerror = ->
      console?.log "Connection Error"
    @dispatcher.onclose = ->
      console?.log "Disconnected"

    @dispatcher.onmessage = (payload) =>
      @appendMessage payload

    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    $('.show-question').on 'click', @showQuestion
    $('.switch-slides-question').on 'click', @switchSlidesQuestion

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

  appendMessage: (payload) =>
    message = JSON.parse payload.data
    console?.log "Message: ", message
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
