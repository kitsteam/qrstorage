// content_type selection:
const contentType = document.querySelector('#content-type-selector');

const showGroups = (contentType) => {
  // hide all content type groups
  document.querySelectorAll('.content-type-group').forEach((contentTypeGroup) => {
    contentTypeGroup.classList.add('visually-hidden');
  });

  // hide all teasers:
  document.querySelectorAll('#teaser li').forEach((contentTypeGroup) => {
    contentTypeGroup.classList.add('d-none');
  });

  // show form for selected content type group:
  const formGroups = document.querySelectorAll('.' + contentType.value);
  formGroups.forEach((formGroup) => {
    formGroup.classList.remove('visually-hidden');
  });

  // show correct teaser:
  const teaser = document.querySelector('#teaser .' + contentType.value);
  if (teaser) {
    teaser.classList.remove('d-none');
  }
}

if (contentType) {
  // show correct groups after page load:
  const currentContentType = document.querySelector('input[name="qr_code[content_type]"]:checked');
  showGroups(currentContentType);

  // show different types of the form:
  // change form based on content type on click:
  document.querySelectorAll('.content-type').forEach((contentType) => {
    contentType.addEventListener('click', (event) => {
      showGroups(contentType);
    });
  });
}