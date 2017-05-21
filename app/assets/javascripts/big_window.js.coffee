class window.BigWindow
  bigWindow: window.open('/big_windows', 'BigWindow',
    'height="' + screen.height + '",width="' + screen.width + '",titlebar=no,fullscreen=yes,menubar=no,location=no,resizable=yes,scrollbars=no,status=no')

  show_slide: true
  full_screen: false

  constructor: ->
    $('.show-question').on 'click', (event) =>
      content = $('.sidebar-question .content').html()
      event.stopPropagation()
      event.stopImmediatePropagation()
      @displayLiveQuestion(content)
      $('.show-question').removeClass('btn-success').addClass('btn-default')
      false

    $('.switch-slide-question').on 'click', (event) =>
      event.stopPropagation()
      event.stopImmediatePropagation()
      @setQuestion()
      false

    $('.switch-slide-slide').on 'click', (event) =>
      event.stopPropagation()
      event.stopImmediatePropagation()
      @setSlide()
      false

  displayLiveSlide: (content) =>
    content = content.replace(/<br>/g, '')
    $(@bigWindow.document.body).find(".content").html(content)

  displayLiveQuestion: (content) =>
    $(@bigWindow.document.body).find(".question").html(content)

  setFullScreen: =>
    @full_screen = true
    @doDisplay()

  setHalfScreen: =>
    @full_screen = false
    @doDisplay()

  setSlide: =>
    @show_slide = true
    @doDisplay()

  setQuestion: =>
    @show_slide = false
    @doDisplay()

  doDisplay: =>
    question = $(@bigWindow.document.body).find(".question")[0]
    slide = $(@bigWindow.document.body).find(".slides")[0]
    full_screen = $(@bigWindow.document.body).find(".full-screen")[0]
    if this.show_slide
      if this.full_screen
        full_screen.style.display = 'block'
        slide.style.display = 'none'
      else
        slide.style.display = 'block'
        full_screen.style.display = 'none'
      question.style.display = 'none'
    else
      full_screen.style.display = slide.style.display = 'none'
      question.style.display = 'block'
