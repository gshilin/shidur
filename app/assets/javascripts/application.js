// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap-sprockets
//= require jquery.cookie
//= require_tree .

var bigWindow = window.open('', 'Big Window', 'height="' + screen.height + '",width="' + screen.width + '",titlebar=no,fullscreen=yes,menubar=no,location=no,resizable=yes,scrollbars=no,status=no');

function gotoSlide() {
    var pageNo = $('#locate-page').find('input').val();
    var slideNo = $('#locate-slide').find('input').val();

    gotoBookmark('author', 'title', pageNo, slideNo);
}

function gotoBookmark(author, title, pageNo, slideNo) {
    $.cookie('current-slide-author', author, {expires: 7, path: '/'});
    $.cookie('current-slide-book', title, {expires: 7, path: '/'});
    $.cookie('current-slide-page', pageNo, {expires: 7, path: '/'});
    $.cookie('current-slide-slide', slideNo, {expires: 7, path: '/'});
    restoreState().then(restoreState1).then(restoreState2).done(function () {
        defer0 = null;
        defer1 = null;
    });
}

function displayLiveSlide(content) {
    $(bigWindow.document.head).html('<meta charset="utf-8"><title>Big Window</title><style>' +
    '* { -moz-box-sizing: border-box; box-sizing: border-box; }' +
    'p {display: none;}' +
    '.wrap { height: 170px; width: 100%; direction: rtl; position: absolute; bottom: 0; left: 0; overflow: hidden; }' +
    '.backdrop { width: 100%; height: 170px; padding: 2% 10%;' +
    'background: -webkit-linear-gradient(left, rgba(201, 191, 177, 0.6) 0%, rgba(201, 191, 177, 0.9) 15%, rgba(201, 191, 177, 0.9) 85%, rgba(201, 191, 177, 0.6) 100%);' +
    'background: linear-gradient(left, rgba(201, 191, 177, 0.6) 0%, rgba(201, 191, 177, 0.9) 15%, rgba(201, 191, 177, 0.9) 85%, rgba(201, 191, 177, 0.6) 100%);' +
    'color: black; text-shadow: 0 0 1px #7d7c7b; font-size: 25px; line-height: 1.2; box-shadow: inset 0 0 40px rgba(0, 0, 0, 0.4); }' +
    '</style>');
    $(bigWindow.document.body).html(content);
}

function activateSlide(self) {
    $('.slides li').removeClass('active');
    var currentSlide = $(self);
    currentSlide.addClass('active');
    $('.navbar-brand').text('דף ' + currentSlide.data('page'));
    var newpos = currentSlide.offset().top - $('.slides ul li').first().offset().top;
    $('.slides ul').animate({
        scrollTop: newpos
    }, 500);
    displayLiveSlide(currentSlide.html());
    storeState(currentSlide);
}

function activateAuthor(self) {
    $('.sidebar-authors li').removeClass('active');
    var current = $(self);
    current.addClass('active');
    $.cookie('current-slide-author', current.find('a').attr('href'), {expires: 7, path: '/'});
}

function activateBook(self) {
    $('.sidebar-books li').removeClass('active');
    var current = $(self);
    current.addClass('active');
    $.cookie('current-slide-book', current.find('a').attr('href'), {expires: 7, path: '/'});
}

function storeState(currentSlide) {
    $.cookie('current-slide-page', currentSlide.data('page'), {expires: 7, path: '/'});
    $.cookie('current-slide-letter', currentSlide.data('letter'), {expires: 7, path: '/'});
}

function restoreState2() {
    var page = $.cookie('current-slide-page'),
        letter = $.cookie('current-slide-letter');

    if (page === undefined) {
        if (letter !== undefined) {
            $('.slides [data-letter="' + letter + '"]').click();
        }
    } else {
        if (letter !== undefined) {
            $('.slides [data-page="' + page + '"][data-letter="' + letter + '"]').click();
        } else {
            $('.slides [data-page="' + page + '"]').click();
        }
    }
}

function restoreState1() {
    $('.sidebar-books [href="' + $.cookie('current-slide-book') + '"]').click();

    defer1 = $.Deferred();
    return defer1.promise();
}

var defer0 = null;
var defer1 = null;

function restoreState() {
    $('.sidebar-authors [href="' + $.cookie('current-slide-author') + '"]').click();
    $('.sidebar-authors [href="' + $.cookie('current-slide-author') + '"]').parent().addClass('active');

    defer0 = $.Deferred();
    return defer0.promise();
}

$(function () {
    restoreState().then(restoreState1).then(restoreState2).done(function () {
        defer0 = null;
        defer1 = null;
    });

    bookmarks.indexedDB.open();

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

    $('.slides').on('click', 'li', function () {
        activateSlide(this);
    });
    $('.sidebar-authors').on('click', 'li', function () {
        activateAuthor(this);
    });
    $('.sidebar-books').on('click', 'li', function () {
        activateBook(this);
    });

    FileHandler.init('load_from_disk');
});

var FileHandler = {
    dropZone: null,
    handleFileSelect: function (evt) {
        evt.stopPropagation();
        evt.preventDefault();
        FileHandler.dropZone.classList.remove('over');

        var file = evt.dataTransfer.files[0],
            reader = new FileReader();

        // Closure to capture the file information.
        reader.onload = (function (theFile) {
            return function (e) {
                var result = e.target.result,
                    lines = result.split(/\n|\r\n/),
                    author = lines[0].split(/ +/).splice(1).join(' '),
                    title = lines[1].split(/ +/).splice(1).join(' ');
                document.getElementById('book_author').value = author;
                document.getElementById('book_title').value = title;
                document.getElementById('book_content').value = result;
            };
        })(file);

        // Read in the image file as a data URL.
        reader.readAsText(file);
    },

    handleDragOver: function (evt) {
        evt.stopPropagation();
        evt.preventDefault();
        evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
    },

    handleDragEnter: function(evt) {
        FileHandler.dropZone.classList.add('over');
    },

    handleDragLeave: function(evt) {
        FileHandler.dropZone.classList.remove('over');
    },

    init: function (id) {
        // Setup the dnd listeners.
        FileHandler.dropZone = document.getElementById(id);
        if (FileHandler.dropZone !== null) {
            FileHandler.dropZone.addEventListener('dragenter', FileHandler.handleDragEnter, false);
            FileHandler.dropZone.addEventListener('dragleave', FileHandler.handleDragLeave, false);
            FileHandler.dropZone.addEventListener('dragover', FileHandler.handleDragOver, false);
            FileHandler.dropZone.addEventListener('drop', FileHandler.handleFileSelect, false);
        }
    }
};
