window.onload = (e) => {
    let container = document.getElementById('favorite-container');
    let btn = document.querySelector('.favorite');
    if (btn) {
        btn.addEventListener('click', (e) => {
            $.ajax({
                url: '/books/add_remove_from_me',
                type: 'post',
                data: { 'book_id': e.target.classList[0] },
                success: function (data, status, xhr) {
                    changeButton(btn, container);
                }
            })
        });
    }
}

function changeButton(btn, container) {
    const bookId = btn.classList[0];
    if (btn.classList[2] == "check") { appendFavoriteOption(bookId, container); }
    else { appendUnfavoriteOption(bookId, container); }
}

function appendFavoriteOption(bookId, container) {
    container.innerHTML = "";

    const favoriteWriting = document.createElement("SMALL");
    favoriteWriting.id = "user-has-book";
    favoriteWriting.innerHTML = "Favorite";

    const favoriteCircle = document.createElement("IMG");
    favoriteCircle.id = "book-add-button";
    favoriteCircle.classList.add(`${bookId}`);
    favoriteCircle.classList.add('favorite');
    favoriteCircle.classList.add('circle');
    favoriteCircle.src = "/images/favicon-circle.png";

    container.appendChild(favoriteWriting);
    container.appendChild(favoriteCircle);
}

function appendUnfavoriteOption(bookId, container) {
    container.innerHTML = "";

    const unfavoriteWriting = document.createElement("SMALL");
    unfavoriteWriting.id = "user-has-book";
    unfavoriteWriting.innerHTML = "Unfavorite";

    const unfavoriteCircle = document.createElement("IMG");
    unfavoriteCircle.id = "book-remove-button";
    unfavoriteCircle.classList.add(`${bookId}`);
    unfavoriteCircle.classList.add('favorite');
    unfavoriteCircle.classList.add('check');
    unfavoriteCircle.src = "/images/favicon-checkmark.png";

    container.appendChild(unfavoriteWriting);
    container.appendChild(unfavoriteCircle);
}

/*<small id="user-has-book">Favorite</small>
<img id="book-add-button" class="<%= @book.id %> favorite circle" src="/images/favicon-circle.png"></img>

const listItem = document.createElement("LI");
        listItem.classList.add('list-item');
        listItem.classList.add(`item-${i + 1}`);

        const bookLink = document.createElement("A");
        bookLink.classList.add('book-link');
        bookLink.classList.add(`link-${i + 1}`);
        bookLink.href = `/books/${bookInfo[i].id}`;

        const bookName = document.createElement("P");
        bookName.classList.add('book-name');
        bookName.classList.add(`name-${i + 1}`);
        bookName.innerHTML = bookInfo[i].title;

        const bookImg = document.createElement("IMG");
        bookImg.classList.add('book-image');
        bookImg.classList.add(`image-${i + 1}`);
        bookImg.src = bookInfo[i].image;

        bookLink.appendChild(bookName);
        bookLink.appendChild(bookImg);
        listItem.appendChild(bookLink);
        ul.appendChild(listItem);*/
