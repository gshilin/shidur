# Event Controller for Question Receiver

$ ->
  window.chat = new Chat

class window.Chat
  template_message: (message) ->
    html =
    """
      <div class="message message-#{message.language}">
        <label class="label label-info" style="font-weight: normal; color: black;">
          [#{message.user_name}]
        </label>&nbsp;
        #{message.message}
      </div>
      """
    $(html)

  template_question: (message) ->
    html =
    """
      <div class="message message-#{message.language}">
        <label class="label label-danger" style="font-weight: normal; color: yellow;">
          [#{message.user_name}]
        </label>&nbsp;
        #{message.message}
      </div>
      """
    $(html)

  dispatcher: null

  constructor: () ->
    url = window.location.hostname + ":4000"

    @message = $('#message')

    @localhost = "http://" + url
    @wsURL = "ws://" + url + "/ws"
    return if @localhost == "http://undefined"

    @connectWS()

    @bindEvents()

#    @endAudio = new Audio('/music/ding.mp3');
#    @endAudio.setAttribute('preload', 'true');

  connectWS: =>
    console?.log "Connecting...."
    @dispatcher = new ReconnectingWebSocket(@wsURL, null, {reconnectInterval: 3000, reconnectDecay: 1})

  disconnectClient: =>
    alert 'disconnect'

  bindEvents: =>
    @dispatcher.onopen = =>
      console?.log "Connected"
      $('.led').removeClass('led-red').addClass('led-green')
      $('#chat').html ""
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
    $('.show-question-he').on 'click', {lang: 'he'}, @showQuestion
    $('.show-question-en').on 'click', {lang: 'en'}, @showQuestion
    $('.show-question-ru').on 'click', {lang: 'ru'}, @showQuestion
    $('.show-question-es').on 'click', {lang: 'es'}, @showQuestion
    $('.switch-slides-slide').on 'click', @setSlide
    $('.switch-direction').on 'click', @switchDirection
    $('.switch-slides-question').on 'click', @setQuestion
    $('.switch-half-screen').on 'click', @setHalfScreen
    $('.switch-full-screen').on 'click', @setFullScreen
    $('.clear-all').on 'click', @clearChat
    $('.clear-button').on 'click', @clearQuestions
    $('.hide-button').on 'click', @hideQuestions

  setFullScreen: =>
    big_window.setFullScreen()
    $('.switch-full-screen').removeClass('btn-danger').addClass('btn-success')
    $('.switch-half-screen').removeClass('btn-success').addClass('btn-danger')

  setHalfScreen: =>
    big_window.setHalfScreen()
    $('.switch-half-screen').removeClass('btn-danger').addClass('btn-success')
    $('.switch-full-screen').removeClass('btn-success').addClass('btn-danger')

  switchDirection: =>
    big_window.switchDirection()
    $('.backdrop').toggleClass('ltr')

  clearQuestions: =>
    $.ajax
      url: @localhost + "/questions"
      type: "post"
      dataType: "json"
      data:
        _method: 'delete'
      success: =>
        $('.sidebar-question .question').html("")
        $('.question-btn').removeClass('btn-success').addClass('btn-default')
      error: (response, status, error) ->
        console.log("Delete messages:", status, "; Error:", error)

  clearChat: =>
    $.ajax
      url: @localhost + "/messages"
      type: "post"
      dataType: "json"
      data:
        _method: 'delete'
      success: =>
        $('.sidebar-question .question').html("")
        $('.question-btn').removeClass('btn-success').addClass('btn-default')
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
        for question in data.last_questions
          $('.sidebar-question .content-' + question.language).html(question.message) unless question.id == 0
      error: (response, status, error) ->
        console.log("List Messages:", status, "; Error:", error)

  hideQuestions: () =>
    big_window.clearLiveQuestion()
    @clearQuestions()

  showQuestion: (event) =>
    lang = event.data.lang
    content = $('.sidebar-question .content-' + lang).html()
    big_window.displayLiveQuestion(content, lang) #if lang == 'he'
    $('.show-question-' + lang).removeClass('btn-success').addClass('btn-default')
    $.ajax
      url: @localhost + "/questions/approve/" + lang
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        console?.log("approved")
      error: (response, status, error) ->
        console?.log("Approval:", status, "; Error:", error)

    false

  setSlide: (event) =>
    event.stopPropagation()
    event.stopImmediatePropagation()
    big_window.setSlide()
    $('.switch-slides-slide').removeClass('btn-danger').addClass('btn-success')
    $('.switch-slides-question').removeClass('btn-success').addClass('btn-danger')
  false

  setQuestion: (event) =>
    event.stopPropagation()
    event.stopImmediatePropagation()
    big_window.setQuestion()
    $('.switch-slides-slide').removeClass('btn-success').addClass('btn-danger')
    $('.switch-slides-question').removeClass('btn-danger').addClass('btn-success')
    false

  sendMessage: (event) =>
    event.preventDefault()
    message = @message.val()
    @dispatcher.send JSON.stringify {user_name: 'נתב', message: message, type: 'message'}
    @message.val('')

  appendMessages: (payload) =>
    message = JSON.parse payload.data
    console?.log "Message: ", message
    messageTemplate = @template_question(message)
    if message.type == 'question'
      @checkNewQuestion message
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140

  appendMessage: (message) =>
    messageTemplate = @template_question(message)
    if message.type == 'question'
      @checkNewQuestion message
    $('#chat').prepend messageTemplate
    messageTemplate.slideDown 140

  checkNewQuestion: (message) =>
    data = message.message
    content = $('.sidebar-question .content-' + message.language)
    old_data = content.html()
    if (data != old_data && message.language != 'cg')
      content.html(data)
      $('.show-question-' + message.language).removeClass('btn-default').addClass('btn-success')
#      @endAudio.play()
