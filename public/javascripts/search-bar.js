window.onload = (e) => {
    const searchBar = document.getElementById('search-bar');
    if (searchBar) {
        let timeOut;
        searchBar.addEventListener('keyup', (e) => {
            if (timeOut) { clearTimeout(timeOut); }
            timeOut = setTimeout(() => { makeRequest(searchBar.value); }, 1000);
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

function appendNames(bookNames, ul) {
    ul.innerHTML = "";
    bookNames = bookNames.names;
    for (let i = 0; i < bookNames.length; i++) {
        const listItem = document.createElement("LI");
        listItem.classList.add('list-item');
        listItem.classList.add(`item-${i + 1}`);

        const bookLink = document.createElement("A");
        bookLink.classList.add('book-link');
        bookLink.classList.add(`link-${i + 1}`);
        bookLink.href = `/books/${bookNames[i]}`;

        const bookName = document.createElement("P");
        bookName.classList.add('book-name');
        bookName.classList.add(`name-${i + 1}`);
        bookName.innerHTML = bookNames[i];

        bookLink.appendChild(bookName);
        listItem.appendChild(bookLink);
        ul.appendChild(listItem);
    }
}
