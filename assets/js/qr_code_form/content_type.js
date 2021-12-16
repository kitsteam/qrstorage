// content_type selection:
const contentType = document.querySelector('#content-type-selector');

const showGroups = (contentType) => {
    // hide all content type groups
    document.querySelectorAll('.content-type-group').forEach((contentTypeGroup) => {
        contentTypeGroup.classList.add('visually-hidden');
    });
    
    // show form for selected content type group:
    const formGroups = document.querySelectorAll('.'+contentType.value);
    formGroups.forEach((formGroup) => {
        formGroup.classList.remove('visually-hidden');
    });
}

const showInputPlaceholder = (contentType) => {
    const textArea = document.querySelector("textarea#text");
    textArea.placeholder = contentType.getAttribute("data-placeholder");
}

if (contentType) {
    // show correct groups after page load:
    const currentContentType = document.querySelector('input[name="qr_code[content_type]"]:checked');
    showGroups(currentContentType);
    showInputPlaceholder(currentContentType);

    // show different types of the form:
    // change form based on content type on click:
    document.querySelectorAll('.content-type').forEach((contentType) => {
        contentType.addEventListener('click', (event) => {  
            showGroups(contentType);
            showInputPlaceholder(contentType);
        }); 
    });
}