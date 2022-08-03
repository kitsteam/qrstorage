const cross = (button) => {
    const cross = '\u2716';
    button.textContent = cross;
}

const check = (button) => {
    const check = '\u2713';
    button.textContent = check;
}

const copyToClipboard = (buttonCopyToClipboard, inputAdminLink) => {
    if (navigator.clipboard === undefined) {
        cross(buttonCopyToClipboard);
        return;
    }

    navigator.clipboard.writeText(inputAdminLink.value).then(function() {
        // writing to clipboard succeeded:
        check(buttonCopyToClipboard);
    }, function() {
        // writing to clipboard failed:
        cross(buttonCopyToClipboard);
    });
}

const buttonCopyToClipboard = document.getElementById("button-copy-to-clipboard");
const inputAdminLink = document.getElementById("input-admin-link");

// copy content of inputAdminLink to clipboard on click:
if (buttonCopyToClipboard) {
    buttonCopyToClipboard.addEventListener('click', (e) => { 
        copyToClipboard(buttonCopyToClipboard, inputAdminLink);
    });
}

// select content of input field so that it's easier to copy
if (inputAdminLink) {
    inputAdminLink.addEventListener('click', (e) => {
        inputAdminLink.select();
    });
}