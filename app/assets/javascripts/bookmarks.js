var bookmarks = {
    indexedDB: {
        db: null,
        dbname: 'bookmarks',
        open: function () {
            var version = 2;
            var request = indexedDB.open(bookmarks.indexedDB.dbname, version);

            // We can only create Object stores in a versionchange transaction.
            request.onupgradeneeded = function (e) {
                var db = e.target.result;

                // A versionchange transaction is started automatically.
                e.target.transaction.onerror = bookmarks.indexedDB.onerror;

                if (db.objectStoreNames.contains(bookmarks.indexedDB.dbname)) {
                    db.deleteObjectStore(bookmarks.indexedDB.dbname);
                }

                var store = db.createObjectStore(bookmarks.indexedDB.dbname, {keyPath: "timeStamp"});
            };

            request.onsuccess = function (e) {
                bookmarks.indexedDB.db = e.target.result;
                bookmarks.bm.getAllBookmarks();
            };

            request.onerror = bookmarks.indexedDB.onerror;
        },
        onerror: function (e) {
            console.log(e.value);
        }
    },
    bm: {
        addBookmark: function (author, book, page, letter, position) {
            var db = bookmarks.indexedDB.db;
            var trans = db.transaction(["bookmarks"], "readwrite");
            var store = trans.objectStore("bookmarks");
            var request = store.put({
                "author": author,
                "book": book,
                "page": page,
                "letter": letter,
                "position": position,
                "timeStamp": new Date().getTime()
            });

            trans.oncomplete = function (e) {
                // Re-render all the bookmarks
                bookmarks.bm.getAllBookmarks();
            };

            request.onerror = function (e) {
                console.log(e.value);
            };
        },
        getAllBookmarks: function () {
            $(".sidebar-bookmarks ul").empty();

            var db = bookmarks.indexedDB.db;
            var trans = db.transaction(["bookmarks"], "readwrite");
            var store = trans.objectStore("bookmarks");

            // Get everything in the store;
            var keyRange = IDBKeyRange.lowerBound(0);
            var cursorRequest = store.openCursor(keyRange);

            cursorRequest.onsuccess = function (e) {
                var result = e.target.result;
                if (!!result === false)
                    return;

                bookmarks.bm.renderBookmark(result.value);
                result.continue();
            };

            cursorRequest.onerror = bookmarks.indexedDB.onerror;
        },
        renderBookmark: function (row) {
            var author = $('.sidebar-authors [href="' + row.author + '"]').text(),
                book = $('.sidebar-books [href="' + row.book + '"]').text(),

                ul = $('.sidebar-bookmarks ul');

            ul.append(
                '<li><a href="#" onclick="gotoBookmark(\'' + row.author + '\', \'' + row.book + '\', \'' + row.page + '\', \'' + row.letter + '\'); return false">' +
                author + ' / ' + book + ' / דף ' + row.page + ' -- אות ' + row.letter +
                '</a>&nbsp;<a href="#" onclick="bookmarks.bm.deleteBookmark(' + row.timeStamp + ')">[מחק]</a></a></li>');

            //a.textContent = " [Delete]";
        },
        deleteBookmark: function (id) {
            var db = bookmarks.indexedDB.db;
            var trans = db.transaction(["bookmarks"], "readwrite");
            var store = trans.objectStore("bookmarks");

            var request = store.delete(id);

            trans.oncomplete = function (e) {
                bookmarks.bm.getAllBookmarks();  // Refresh the screen
            };

            request.onerror = function (e) {
                console.log(e);
            };
        }
    }
};
