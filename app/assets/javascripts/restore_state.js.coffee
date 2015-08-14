class window.RestoreState
  constructor: ->
    $('.sidebar-authors').on 'click', 'li', (event) =>
      event.preventDefault()
      author = $(event.target).text()
      @activateAuthor event.target, author
      false

    $('.sidebar-books').on 'click', 'li', (event) =>
      event.preventDefault()
      book = $(event.target).attr('href')
      @activateBook event.target, book
      false

  remote: =>
    author = $.cookie('current-slide-author')
    return if (author == '' || author == undefined)
    @activateAuthor $('.sidebar-authors [href="' + author.replace('"', '\\"') + '"]').parent(), author

    book = $.cookie('current-slide-book')
    return if (typeof book == 'undefined' || book == undefined)
    @activateBook $('.sidebar-books [href="' + book.replace('"', '\\"') + '"]').parent(), book

  local: =>
    page = $.cookie('current-slide-page')
    letter = $.cookie('current-slide-letter')
    $('#locate-page').find('input').val(page)
    $('#locate-slide').find('input').val(letter)

    books.gotoSlide()

  activateAuthor: (element, author) ->
    current = $(element)
    $('.sidebar-authors li').removeClass('active')
    current.closest('li').addClass('active')

    $.cookie('current-slide-author', author, {expires: 7, path: '/'})

    titles = books.books[author]
    $('.slides ul').empty()
    $('.sidebar-books ul').html(titles)

  activateBook: (element, book) ->
    current = $(element)
    $('.sidebar-books li').removeClass('active')
    current.closest('li').addClass('active')

    $.cookie('current-slide-book', book, {expires: 7, path: '/'})
    books.loadSlides(book)

