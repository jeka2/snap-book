window.onload = (e) => {
    const errorFlash = document.getElementById('flash');
    const closeButton = document.getElementById('close');
    if (errorFlash) {
        closeButton.addEventListener('click', () => {
            errorFlash.remove();
        })
    }
}