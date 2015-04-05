var BigWindow = {
    bigWindow: window.open('/big_windows', 'Big Window', 'height="' + screen.height + '",width="' + screen.width + '",titlebar=no,fullscreen=yes,menubar=no,location=no,resizable=yes,scrollbars=no,status=no'),

    show_slide: true,

    displayLiveSlide: function (content) {
        $(this.bigWindow.document.body).find(".content").html(content);
    },

    displayLiveQuestion: function (content) {
        $(this.bigWindow.document.body).find(".question ").html(content);
    },

    switchSlidesQuestion: function () {
        var question = $(this.bigWindow.document.body).find(".question")[0];
        var slide = $(this.bigWindow.document.body).find(".slides")[0];
        this.show_slide = !this.show_slide;
        slide.style.display = this.show_slide ? 'block' : 'none';
        question.style.display = this.show_slide ? 'none' : 'block';
    }
};

Handlebars.registerHelper('calcSubletter', function () {
    var subletter = this.subletter;
    return subletter === 1 ? "" : ("-" + subletter);
});

var RestoreState = {
    remote: function () {
        var author = $.cookie('current-slide-author');
        if (author === '') return;
        activateAuthor($('.sidebar-authors [href="' + author + '"]').parent());
        var book = $.cookie('current-slide-book');
        if (typeof book === 'undefined') return;
        activateBook($('.sidebar-books [href="' + book + '"]').parent());
    },

    local: function () {
        var page = $.cookie('current-slide-page'),
            letter = $.cookie('current-slide-letter');
        $('#locate-page').find('input').val(page);
        $('#locate-slide').find('input').val(letter);
        gotoSlide();
    }
};


var source;
var template;

function drawSlides(slides_array) {
    var slides = {slides: slides_array};
    $('.slides ul').html(template(slides));
}

function gotoSlide() {
    var page = $('#locate-page').find('input').val();
    var letter = $('#locate-slide').find('input').val();

    if (page === undefined || page === '') {
        if (letter !== undefined && letter !== '') {
            $('.slides [data-letter="' + letter + '"]').click();
        }
    } else {
        if (letter !== undefined && letter !== '') {
            $('.slides [data-page="' + page + '"][data-letter="' + letter + '"]').click();
        } else {
            $('.slides [data-page="' + page + '"]').first().click();
        }
    }
}

function gotoBookmark(author, title, pageNo, slideNo) {
    $.cookie('current-slide-author', author, {expires: 7, path: '/'});
    $.cookie('current-slide-book', title, {expires: 7, path: '/'});
    $.cookie('current-slide-page', pageNo, {expires: 7, path: '/'});
    $.cookie('current-slide-letter', slideNo, {expires: 7, path: '/'});
    RestoreState.remote();
}

function activateSlide(self) {
    $('.slides li').removeClass('active');
    var currentSlide = $(self);
    currentSlide.addClass('active');
    $('.navbar-brand').text('דף ' + currentSlide.data('page') + ' שקף ' + currentSlide.data('letter')).data('page', currentSlide.data('page')).data('letter', currentSlide.data('letter'));
    var newpos = currentSlide.offset().top - $('.slides ul li').first().offset().top;
    $('html, body').animate({
        scrollTop: newpos
    }, 500);
    BigWindow.displayLiveSlide(currentSlide.html());
    $.cookie('current-slide-page', currentSlide.data('page'), {expires: 7, path: '/'});
    $.cookie('current-slide-letter', currentSlide.data('letter'), {expires: 7, path: '/'});
}

function activateAuthor(self) {
    var current = $(self);
    $('.sidebar-authors li').removeClass('active');
    current.addClass('active');

    var author = current.text();
    $.cookie('current-slide-author', author, {expires: 7, path: '/'});

    var titles = books[author];
    $('.slides ul').empty();
    $('.sidebar-books ul').html(titles);
}

function activateBook(self) {
    var current = $(self);
    $('.sidebar-books li').removeClass('active');
    current.addClass('active');

    var href = current.find('a').attr('href');
    $.cookie('current-slide-book', href, {expires: 7, path: '/'});
    var l = window.location,
        url = l.protocol + '//' + l.host + href;
    $.getScript(url);
}

$(function () {
    source = $('#slides-template').html();
    if (source !== undefined) {
        template = Handlebars.compile(source);
    }

    if (typeof(books) !== "undefined") {
        RestoreState.remote();

        bookmarks.indexedDB.open();
    }

    $('.show-question').on('click', function (event) {
        var content = $('.sidebar-question .content').html();
        BigWindow.displayLiveQuestion(content);
        $('.show-question').removeClass('btn-success').addClass('btn-default');
    });

    $('.switch-slides-question').on('click', function (event) {
        event.stopPropagation();
        event.stopImmediatePropagation();
        BigWindow.switchSlidesQuestion();
        return false;
    });

    $('.sidebar-navigation form').on('submit', function (event) {
        event.stopPropagation();
        event.stopImmediatePropagation();
        gotoSlide();
        return false;
    });

    $('.sidebar-bookmarks ul').droppable({
        activeClass: "ui-state-highlight",
        //greedy: true,
        hoverClass: "drop-hover",
        tolerance: 'pointer',
        drop: function (event, ui) {
            var author = $.cookie('current-slide-author'),
                book = $.cookie('current-slide-book'),
                page = ui.draggable.data('page'),
                letter = ui.draggable.data('letter');
            bookmarks.bm.addBookmark(author, book, page, letter);
        }
    });

    $('.authors').on('click', 'li', function (event) {
        activateAuthor(this);
        return false;
    });

    $('.slides').on('click', 'li', function () {
        activateSlide(this);
        return false;
    });

    $('.sidebar-books').on('click', 'li', function () {
        activateBook(this);
        return false;
    });

    $('.navbar-header').on('click', '.navbar-brand', function (evt) {
        evt.stopPropagation();
        evt.preventDefault();

        var page = $(this).data('page');
        var letter = $(this).data('letter');
        $('.slides [data-page="' + page + '"][data-letter="' + letter + '"]').click();
    });

    fileHandlerController.init('#load_from_disk');

    $('.validate').on('click', '', function (evt) {
        evt.stopPropagation();
        //evt.preventDefault();

        var form = $(this).closest('form');
        form.attr('action', '/admin/books/validate');
        form.find("input[name='_method']").attr('value', 'post')
    });
});
