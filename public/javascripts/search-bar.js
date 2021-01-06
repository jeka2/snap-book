window.onload = (e) => {
    const searchBar = document.getElementById('search-bar');
    let listItem = document.getElementById('search-results');
    let timeOut;
    searchBar.addEventListener('keyup', (e) => {
        if (timeOut) { clearTimeout(timeOut); }
        timeOut = setTimeout(() => { getBooks(searchBar.value, listItem); }, 500);
    });
    window.addEventListener('click', (e) => {
        if (listItem.firstChild) { // if the search bar has results
            listItem.innerHTML = "";
        }
    });
}

async function getBooks(title, list) {
    let listItem = document.getElementById('search-results');
    let result;

    try {
        result = await $.ajax({
            url: '/test',
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
    console.log(bookInfo)
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
