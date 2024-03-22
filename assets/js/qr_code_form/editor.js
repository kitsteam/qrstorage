import Quill from 'quill'
import ImageCompress from 'quill-image-compress';

const isFormTooLarge = (form, htmlInput) => {
  // get maximum upload size from form 
  const maxUploadLength = form.getAttribute('data-max-upload-length');

  // we use TextEncoder instead of .length, since emojis use 4 bytes instead of 2, because they are UTF encoded. Blob() accounts for this.
  const estimatedFormLength = new TextEncoder().encode(htmlInput).length;

  return estimatedFormLength > maxUploadLength;
}

const validateFormSize = (form, htmlInput) => {
  const uploadWarning = document.querySelector('#upload-size-warning');

  // show error message / prevent form submit when too large:
  if (isFormTooLarge(form, htmlInput)) {
    // make warning visible;
    uploadWarning.classList.remove("d-none");
    return false;
  }

  // hide warning:
  uploadWarning.classList.add("d-none");

  return true;
}

Quill.register('modules/counter', function (quill, options) {
  const container = document.querySelector(options.container);
  quill.on('text-change', () => {
    const text = quill.getText();
    const maxCharacters = container.getAttribute('data-max-characters');
    const charactersLeft = maxCharacters - text.trim().length;

    container.innerText = charactersLeft;

    // limit to maxCharacters:
    if (charactersLeft <= 0) {
      quill.deleteText(maxCharacters, quill.getLength());
    }
  });
});

const editorContainer = document.querySelector("#editor-container")


if (editorContainer) {

  var ColorClass = Quill.import('attributors/class/color');
  Quill.register(ColorClass, true);
  var BackgroundClass = Quill.import('attributors/class/background');
  Quill.register(BackgroundClass, true);
  Quill.register("modules/imageCompress", ImageCompress);

  const quill = new Quill('#editor-container', {
    modules: {
      imageCompress: {
        quality: 0.9,
        maxWidth: 1500, // default
        maxHeight: 1500, // default
        imageType: 'image/png',
        keepImageTypes: ['image/jpeg', 'image/png'],
        ignoreImageTypes: ['image/gif']
      },
      toolbar: [
        ['bold', 'italic', 'underline', 'strike'],
        ['link', 'image'],
        [{ 'align': ['', 'center', 'right'] }, { 'list': 'ordered' }, { 'list': 'bullet' }],
        [{ 'color': [] }, { 'background': [] }]
      ],
      counter: {
        container: '#character-count'
      }
    },
    theme: 'snow'  // or 'bubble'
  });

  // change the link placeholder, default is quilljs.com
  const tooltip = quill.theme.tooltip;
  const input = tooltip.root.querySelector("input[data-link]");
  input.dataset.link = 'https://kits.blog';

  // if deltas are present, load them:
  deltasJson = document.querySelector('#deltas').value;

  if (deltasJson) {
    try {
      parsedJson = JSON.parse(deltasJson);
      quill.setContents(parsedJson);
    } catch (exception) {
      // no need to handle this - just leave the text editor blank
      console.error("Deltas JSON could not be parsed.");
    }
  }

  const form = document.querySelector('form#text');
  form.onsubmit = () => {
    // Populate hidden form on submit
    const htmlInput = document.querySelector('textarea[id=html]');
    htmlInput.value = quill.root.innerHTML;

    const deltaInput = document.querySelector('textarea[id=deltas]');
    deltaInput.value = JSON.stringify(quill.getContents());

    formIsValid = validateFormSize(form, quill.root.innerHTML);

    return formIsValid;
  };
}