# Event Controller for Question Writer

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
    @dispatcher = new WebSocketRails(url, useWebSockets)
    @dispatcher.on_close = @disconnectClient
    @bindEvents()

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.bind 'new_message', @appendMessage
    @dispatcher.bind 'got_new_question', @appendMessage
    $('#question').on 'click', @sendQuestion
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  sendQuestion: (event) =>
    $question = $('#question_question')
    event.preventDefault()
    message = $question.val()
    @dispatcher.trigger 'new_question', {user_name: 'עורך', msg_body: message}

  sendMessage: (event) =>
    $message = $('#message')
    event.preventDefault()
    message = $message.val()
    @dispatcher.trigger 'new_message', {user_name: 'עורך', msg_body: message}
    $message.val('')

  appendMessage: (message) =>
    messageTemplate = @template(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140
