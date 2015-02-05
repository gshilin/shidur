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
    @messageQueue = []
    @dispatcher = new WebSocketRails(url, useWebSockets)
    @dispatcher.on_close = @disconnectClient
    @bindEvents()

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.bind 'new_message', @newMessage
    $('#question').on 'click', @sendQuestion
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  # new message from pair
  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 10
    @appendMessage message

  sendQuestion: (event) =>
    $question = $('#question_question')
    event.preventDefault()
    message = $question.val()
    @dispatcher.trigger 'new_question', {user_name: 'שאלות', msg_body: message}
    $question.val('')

  sendMessage: (event) =>
    $message = $('#message')
    event.preventDefault()
    message = $message.val()
    @dispatcher.trigger 'new_message', {user_name: 'שאלות', msg_body: message}
    $message.val('')

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#chat').append messageTemplate
    messageTemplate.slideDown 140

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat .message:first').slideDown 100, ->
      $(this).remove()
