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
    @messageQueue = []
    unless url == undefined
      @dispatcher = new WebSocketRails(url, useWebSockets)
      @dispatcher.on_close = @disconnectClient
      @bindEvents()

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'got_new_question', @gotNewQuestion
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13
    $('.show-question').on 'click', @showQuestion
    $('.switch-slides-question').on 'click', @switchSlidesQuestion

  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 10
    @appendMessage message

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
    @dispatcher.trigger 'new_message', {user_name: 'נטב', msg_body: message}
    $message.val('')

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#chat').append messageTemplate
    messageTemplate.slideDown 140

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat .message:first').slideDown 100, ->
      $(this).remove()
