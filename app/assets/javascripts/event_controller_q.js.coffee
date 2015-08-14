# Event Controller for Question Author
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
    @message = $('#message')
    @question = $('#question_question')

    @dispatcher = new WebSocket(url)
    @bindEvents()

  bindEvents: =>
    @dispatcher.onopen = ->
      console?.log "Connected"
    @dispatcher.onerror = ->
      console?.log "Connection Error"
    @dispatcher.onclose = ->
      console?.log "Disconnected"

    @dispatcher.onmessage = (payload) =>
      @appendMessage payload

    $('#question').on 'click', @sendQuestion
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  sendQuestion: (event) =>
    event.preventDefault()
    message = @question.val()
    @dispatcher.send JSON.stringify {user_name: 'עורך', message: message, type: 'question'}

  sendMessage: (event) =>
    event.preventDefault()
    message = @message.val()
    @dispatcher.send JSON.stringify {user_name: 'עורך', message: message, type: 'message'}
    @message.val('')

  appendMessage: (payload) =>
    message = JSON.parse payload.data
    console?.log "Message: ", message
    if message.type == 'question'
      messageTemplate = @template_question(message)
    else
      messageTemplate = @template_message(message)
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140
