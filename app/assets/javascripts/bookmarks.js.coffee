class window.Bookmarks
  constructor: (url) ->
    template = """
      {{#each bookmarks}}
      <li>
        <a href="#" onclick="bookmarks.gotoBookmark({{id}}); return false"> {{author}}/{{book_name}}/דף {{page}}/אות {{letter}}
          &nbsp;
          <a href="#" onclick="bookmarks.deleteBookmark({{id}})">[מחק]</a>
        </a>
      </li>
      {{/each}}
    """
    template_manager.load_template 'bookmarks', template

    @localhost = "http://" + url
    @bookmarks = null
    @getAllBookmarks()

    $('.sidebar-bookmarks ul').droppable
      activeClass: "ui-state-default"
      hoverClass: "drop-hover"
      tolerance: 'pointer'
      drop: (event, ui) =>
        author = $.cookie 'current-slide-author'
        book = $.cookie 'current-slide-book'
        page = ui.draggable.data 'page'
        letter = ui.draggable.data 'letter'
        book_name = ui.draggable.data 'book_name'
        @addBookmark author, book, page, letter, book_name

  addBookmark: (author, book, page, letter, book_name) =>
    $.ajax
      url: "/bookmarks.json"
      type: "POST"
      dataType: "json"
      data:
        author: author
        book: book
        page: page
        letter: letter
        book_name: book_name
      success: (data, status, response) =>
        @getAllBookmarks()
      error: (response, status, error) ->
        console.log("Add Bookmark:", status, "; Error:", error);

  getAllBookmarks: =>
    return if @localhost == "http://undefined"

    $.ajax
      url: @localhost + "/bookmarks"
      type: "GET"
      dataType: "json"
      success: (data, status, response) =>
        @bookmarks = data
        $(".sidebar-bookmarks ul").html(@template(@bookmarks))
      error: (response, status, error) ->
        console.log("List Bookmarks:", status, "; Error:", error);

  template: =>
    html = template_manager.transform 'bookmarks', @bookmarks
    $(html)

  gotoBookmark: (id) =>
    bookmark = $.grep bookmarks.bookmarks.bookmarks, (el) ->
      el.id == id
    books.gotoBookmark bookmark[0].author, bookmark[0].book, bookmark[0].page, bookmark[0].letter

  deleteBookmark: (id) =>
    id = Number(id)
    $.ajax
      url: "/bookmarks/" + id + ".json"
      type: "DELETE"
      success: (data, status, response) =>
        console.log("Bookmark", id, "was successfully deleted")
        @getAllBookmarks()
      error: (response, status, error) ->
        console.log("Delete Bookmark:", id, status, "; Error:", error);
