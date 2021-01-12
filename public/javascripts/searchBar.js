window.onload = (e) => {

    favorite();

    flash();

    imageCheck();

    const searchBar = document.getElementById('search-bar');
    let listItem = document.getElementById('search-results');
    let timeOut;
    searchBar.addEventListener('keyup', (e) => {
        if (timeOut) { clearTimeout(timeOut); }
        timeOut = setTimeout(() => { getBooks(searchBar.value, listItem); }, 500);

        if (e.key == "Backspace" && searchBar.value == "") {
            listItem.innerHTML = "";
            if (timeOut) { clearTimeout(timeOut); }
        }
    });
    window.addEventListener('click', (e) => {
        if (listItem.firstChild && e.target.id != searchBar.id) {
            listItem.innerHTML = "";
        }
    });
}

async function getBooks(title, list) {
    let listItem = document.getElementById('search-results');
    let result;

    try {
        result = await $.ajax({
            url: '/books/search_bar',
            type: 'GET',
            data: { 'title': title },
            success: function (data, status, xhr) {
                appendNames(data, list);
            },
            dataType: "json"
        });
    } catch (e) {

    }
}

function appendNames(bookInfo, ul) {
    ul.innerHTML = "";
    for (let i = 0; i < bookInfo.length; i++) {
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
        ul.appendChild(listItem);
    }
}
///////////////////////////////////
function favorite() {
    let containers = document.querySelectorAll('.favorite-container');
    if (containers) {
        for (let i = 0; i < containers.length; i++) {
            addFavoriteEventListenerToButtons(containers[i]);
        }
    }
}

function addFavoriteEventListenerToButtons(container) {
    console.log(container.childNodes)
    let text = container.childNodes[1];
    let btn = container.childNodes[3];
    btn.addEventListener('click', (e) => {
        e.preventDefault();
        let imgClass = e.target.classList[2];
        let action = (imgClass == "check") ? "remove" : "add";
        let type = (imgClass == "check") ? "DELETE" : "POST";
        $.ajax({
            url: `/books/self_${action}`,
            type: type,
            data: { 'book_id': e.target.classList[0] },
            success: function (data, status, xhr) {
                changeButton(container);
            }
        });
    });
}

function changeButton(container) {
    let txtNode = container.childNodes[1];
    let imgNode = container.childNodes[3];
    let imgClass = imgNode.classList[2];

    let replacementClass = (imgClass == "check") ? "circle" : "check";
    let replacementTxt = (imgClass == "check") ? "Favorite" : "Unfavorite";
    let replacementImgSrc = (imgClass == "check") ? "/images/favicon-circle.png" : "/images/favicon-checkmark.png";

    imgNode.classList.remove(imgClass);
    imgNode.classList.add(replacementClass);
    imgNode.src = replacementImgSrc;
    txtNode.innerHTML = replacementTxt;
}

///////////////////////////

function flash() {
    const flash = document.getElementById('flash');
    const closeButton = document.getElementById('close');
    if (flash) {
        setTimeout(() => { flash.remove(); }, 3000);
        closeButton.addEventListener('click', () => {
            flash.remove();
        })
    }
}
////////////////////////////

function imageCheck() {
    let size;
    if (window.location.href.match(/.*\/users\/.*\/books/)) {
        size = 'M';
    }
    else {
        size = 'L';
    }
    const coverInfo = document.querySelectorAll('.cover-info');
    if (coverInfo.length > 0) {
        for (let i = 0; i < coverInfo.length; i++) {
            let img = coverInfo[i].childNodes[1];
            if (img.height === 1) {
                img.src = `/images/default-cover-${size}.jpg`;
                coverInfo[i].childNodes[4].innerHTML = "";
            }
        }
    }
}


