window.onload = (e) => {
    const searchBar = document.getElementById('search-bar');
    if (searchBar) {
        // Keydown shouldn't fire if nothing is present in the field
        searchBar.addEventListener('keydown', (e) => {           
                let results = document.getElementById('search-results');
                let listItem = document.getElementsByClassName('list-item');
                console.log(listItem.length)

                $.get("/test", (data) => {
                    const parsedData = JSON.parse(data);
                    const bookNames = parsedData.names;

                    for(let i = 0; i < bookNames.length; i++){
                        const listItem = document.createElement("LI");
                        listItem.classList.add('list-item');
                        listItem.classList.add(`item-${i+1}`);

                        const bookLink = document.createElement("A");
                        bookLink.classList.add('book-link');
                        bookLink.classList.add(`link-${i+1}`);
                        bookLink.href = `/books/${bookNames[i]}`;

                        const bookName = document.createElement("P");
                        bookName.classList.add('book-name');
                        bookName.classList.add(`name-${i+1}`);
                        bookName.innerHTML = bookNames[i];

                        bookLink.appendChild(bookName);
                        listItem.appendChild(bookLink);
                        results.appendChild(listItem);
                    }
                });
        });
    }
}

function removeAllLiNodes(parent) {
    while(parent.firstChild) {
        parent.removeChild(parent.firstChild);
    }
}
