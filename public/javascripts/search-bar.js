window.onload = (e) => {
    const searchBar = document.getElementById('search-bar');
    if (searchBar) {
        let timeOut;
        searchBar.addEventListener('keyup', (e) => {
            if (timeOut) { clearTimeout(timeOut); }
            timeOut = setTimeout(() => { makeRequest(searchBar.value); }, 500);
        });
    }
}

function makeRequest(enteredInfo) {
    getBooks(enteredInfo);
}

async function getBooks(name) {
    let listItem = document.getElementById('search-results');
    let result;

    try {
        result = await $.ajax({
            url: '/test',
            type: 'GET',
            data: { 'name': name },
            success: function (data, status, xhr) {
                appendNames(data, listItem);
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
        bookLink.href = `/books/${bookInfo[i].title}`;

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
