class window.Books
  constructor: (url) ->
    @localhost = "http://" + url
    @books = new Array

    template = """
        {{#each slides}}
        <li class="draggable" data-page="{{ page }}" data-letter="{{ letter }}{{ calcSubletter }}" data-book_name="{{ ../book_name }}">
          <div class="wrap {{ calcRevert }}">
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

    @loadAllBooks()
    @setCallbacks()

  setCallbacks: =>
    $('.slides').on 'click', 'li', (event) =>
      event.preventDefault()
      @activateSlide event.target
      false

    $('#locate-page, #locate-slide').on 'submit', (event) =>
      event.stopPropagation()
      event.stopImmediatePropagation()
      @gotoSlide()
      false

    # jump to h3
    $('.sidebar-h3').on 'click', 'a', (event) =>
      event.preventDefault()
      target = $(event.target)
      page = target.data('page')
      letter = target.data('letter')
      @gotoSlide(page, letter)
      $('.sidebar-h3').click()
      $('.sidebar-s3 li').removeClass('active')
      target.closest('li').addClass('active')

    false

  loadTemplates: =>
    template = """
      {{#each slides}}
      <li class="draggable" data-page="{{ page }}" data-letter="{{ letter }}{{ calcSubletter }}" data-book_name="{{ ../book_name }}">
        <div class="wrap {{ calcRevert }}">
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

  loadAllBooks: =>
    return if @localhost == "http://undefined"

    $.ajax
      url: @localhost + "/books"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        @books = data
        @drawAuthors()
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
      url: @localhost + book
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        book_name = Object.keys(data)[0]
        data = JSON.parse(data[book_name])
        @drawSlides(book_name, data)
        @drawLinks(data)
        restore_state.local()
        $('.slides .draggable').draggable({
          revert: true,
          handle: 'span'
        })
      error: (response, status, error) ->
        console.log("Load Book:", status, "; Error:", error)

  drawSlides: (book_name, slides) =>
    html = template_manager.transform 'slides', {book_name: book_name, slides: slides}
    $('.slides ul').html html

  drawAuthors: =>
    html = template_manager.transform 'authors', {authors: Object.keys(@books).sort()}
    $('ul.sidebar-authors').html html

  drawLinks: (slides) =>
    html = ''
    for {page, letter, subletter, content} in slides
      if content.match /h3/
        l = letter
        l += '-' + subletter if subletter != '1'
        html += content.replace /<h3>(.+)<\/h3>/, "<li><a href='#' data-page='" + page + "' data-letter='" + l + "'>$1</a></li>"
    $('ul.sidebar-h3').html html

  gotoSlide: (page, letter) =>
    page ?= $('#locate-page').find('input').val()
    letter ?= $('#locate-slide').find('input').val()

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
