window.onload = (e) => {
    console.log('hi')
    const errorFlash = document.getElementById('flash');
    const closeButton = document.getElementById('close');
    if (errorFlash) {
        closeButton.addEventListener('click', () => {
            errorFlash.remove();
        })
    }
}
document.addEventListener('DOMContentLoaded', (e) => {

})