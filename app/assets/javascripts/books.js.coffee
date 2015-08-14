class window.Books
  constructor: ->
    template = """
      {{#each slides}}
      <li class="draggable" data-page="{{ page }}" data-letter="{{ letter }}{{ calcSubletter }}">
        <div class="wrap">
          <div class="backdrop">
            <span class="handle glyphicon glyphicon-move"/>
            {{{content}}}
          </div>
        </div>
      </li>
      {{/each}}
    """
    template_manager.load_template 'slides', template

    template = """
      {{#each authors}}
        <li><a href="{{this}}">{{this}}</a></li>
      {{/each}}
    """
    template_manager.load_template 'authors', template

    @books = new Array
    @loadAllBooks()

    $('.slides').on 'click', 'li', (event) =>
      event.preventDefault()
      @activateSlide event.target
      false

    $('.sidebar-navigation form').on 'submit', (event) =>
      event.stopPropagation()
      event.stopImmediatePropagation()
      @gotoSlide()

  loadAllBooks: =>
    $.ajax
      url: "/books.json"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        @books = data
        @drawAuthors(@books)
        restore_state.remote()
      error: (response, status, error) ->
        console.log("List Bookmarks:", status, "; Error:", error);

  gotoBookmark: (author, title, pageNo, slideNo) =>
    $.cookie('current-slide-author', author, {expires: 7, path: '/'})
    $.cookie('current-slide-book', title, {expires: 7, path: '/'})
    $.cookie('current-slide-page', pageNo, {expires: 7, path: '/'})
    $.cookie('current-slide-letter', slideNo, {expires: 7, path: '/'})
    restore_state.remote()

  loadSlides: (book) =>
    $.ajax
      url: book
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        @drawSlides(data)
        restore_state.local()
        $('.slides .draggable').draggable({
          revert: true,
          handle: 'span'
        })
      error: (response, status, error) ->
        console.log("Load Book:", status, "; Error:", error)

  drawSlides: (slides) =>
    html = template_manager.transform 'slides', {slides: slides}
    $('.slides ul').html html

  drawAuthors: (authors) =>
    html = template_manager.transform 'authors', {authors: Object.keys(authors)}
    $('ul.list-unstyled.authors').html html

  gotoSlide: =>
    page = $('#locate-page').find('input').val()
    letter = $('#locate-slide').find('input').val()

    if (page == undefined || page == '')
      if (letter != undefined && letter != '')
        $('.slides [data-letter="' + letter + '"]').click()
    else
      if (letter != undefined && letter != '')
        $('.slides [data-page="' + page + '"][data-letter="' + letter + '"]').click()
      else
        $('.slides [data-page="' + page + '"]').first().click()

  activateSlide: (self) =>
    $('.slides li').removeClass('active')
    currentSlide = $(self).closest('li')
    currentSlide.addClass('active')
    $('.navbar-brand').text('דף ' + currentSlide.data('page') + ' שקף ' + currentSlide.data('letter')).data('page',
      currentSlide.data('page')).data('letter', currentSlide.data('letter'))
    newpos = currentSlide.offset().top - $('.slides ul li').first().offset().top
    $('html, body').animate({
      scrollTop: newpos
    }, 500)
    big_window.displayLiveSlide(currentSlide.html())
    $.cookie('current-slide-page', currentSlide.data('page'), {expires: 7, path: '/'})
    $.cookie('current-slide-letter', currentSlide.data('letter'), {expires: 7, path: '/'})
