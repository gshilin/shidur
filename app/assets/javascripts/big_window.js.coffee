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

    @carousel()

  displayLiveSlide: (content) =>
    content = content.replace(/<br>/g, '')
    $(@bigWindow.document.body).find(".content").html(content)

  clearLiveQuestion: =>
    window.clearTimeout(@lastTimeout)
    @lastTimeout = undefined
    $(@bigWindow.document.body).find(".question").html('').css('display', 'none')
    $(@bigWindow.document.body).find(".questions").css('display', 'none')
    @slides = []
    @slideIndex = 1

  displayLiveQuestion: (content, lang) =>
    q = $(@bigWindow.document.body).find(".question-" + lang)
    q.html(content)
    @slides.push(q)
    if !this.show_slide
       $(@bigWindow.document.body).find(".questions").css('display', 'block')
    if @lastTimeout == undefined
      @carousel()

  slideIndex: 1
  slides: []
  lastTimeout: undefined

  carousel: =>
    if @slides[@slideIndex - 1]
      @slides[@slideIndex - 1].css('display', 'none')
    @slideIndex++
    if @slideIndex > @slides.length
      @slideIndex = 1
    if @slides[@slideIndex - 1]
      @slides[@slideIndex - 1].css('display', 'block')
    # Change image every 10 seconds
    @lastTimeout = setTimeout(@carousel, 10000)

  setFullScreen: =>
    @full_screen = true
    @show_slide = true
    @doDisplay()

  setHalfScreen: =>
    @full_screen = false
    @show_slide = true
    @doDisplay()

  setSlide: =>
    @show_slide = true
    @doDisplay()

  setQuestion: =>
    @show_slide = false
    @doDisplay()

  doDisplay: =>
    questions = $(@bigWindow.document.body).find(".questions")[0]
    slide = $(@bigWindow.document.body).find(".slides")[0]
    full_screen = $(@bigWindow.document.body).find(".full-screen")[0]
    if this.show_slide
      if this.full_screen
        full_screen.style.display = 'block'
        slide.style.display = 'none'
      else
        slide.style.display = 'block'
        full_screen.style.display = 'none'
      questions.style.display = 'none'
    else
      full_screen.style.display = slide.style.display = 'none'
      questions.style.display = 'block'
