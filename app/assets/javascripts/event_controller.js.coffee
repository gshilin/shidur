# Event Controller for Question Receiver

jQuery ->
  window.chatController = new Chat.Controller($('#chat').data('uri'), true)

window.Chat = {}

class Chat.Controller
  template: (message) ->
    html =
    """
      <div class="message" >
        <label class="label label-info" style="direction: ltr; font-weight: normal; color: black;">
          [#{message.user_name}]
        </label>&nbsp;
        #{message.msg_body}
      </div>
    """
    $(html)

  constructor: (url, useWebSockets) ->
    unless url == undefined
      @dispatcher = new WebSocketRails(url, useWebSockets)
      @dispatcher.on_close = @disconnectClient
      @bindEvents()

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.bind 'new_message', @appendMessage
    @dispatcher.bind 'got_new_question', @gotNewQuestion
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    $('.show-question').on 'click', @showQuestion
    $('.switch-slides-question').on 'click', @switchSlidesQuestion

  gotNewQuestion: (message) =>
    @appendMessage message
    data = message.msg_body
    $content = $('.sidebar-question .content')
    old_data = $content.html()
    if (data != old_data)
      $('.show-question').removeClass('btn-default').addClass('btn-success');
      $content.html(data);

  showQuestion: (event) =>
    content = $('.sidebar-question .content').html()
    BigWindow.displayLiveQuestion(content)
    $('.show-question').removeClass('btn-success').addClass('btn-default')
    false

  switchSlidesQuestion: (event) =>
    event.stopPropagation()
    event.stopImmediatePropagation()
    BigWindow.switchSlidesQuestion()
    false

  sendMessage: (event) =>
    $message = $('#message')
    event.preventDefault()
    message = $message.val()
    @dispatcher.trigger 'new_message', {user_name: 'נתב', msg_body: message}
    $message.val('')

  appendMessage: (message) =>
    messageTemplate = @template(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140
