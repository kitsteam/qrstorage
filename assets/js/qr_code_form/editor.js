import Quill from 'quill'


Quill.register('modules/counter', function(quill, options) {
    const container = document.querySelector(options.container);
    quill.on('text-change', () => {
      const text = quill.getText();
      const maxCharacters = container.getAttribute('data-max-characters');
      const charactersLeft = maxCharacters - text.trim().length

      container.innerText = charactersLeft;

      // limit to maxCharacters:
      if (charactersLeft <= 0) {
        quill.deleteText(maxCharacters, quill.getLength());
      }
    });
  });

const editorContainer = document.querySelector("#editor-container")

if (editorContainer) {
    const quill = new Quill('#editor-container', {
        modules: {
          toolbar: [
            ['bold', 'italic', 'underline', 'strike'],
            ['link'],
            [ {'align': ['', 'center', 'right'] }, { 'list': 'ordered'}, { 'list': 'bullet' }],
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
      deltasJson = document.querySelector('#deltas').value
      if (deltasJson) {
        try {
          parsedJson = JSON.parse(deltasJson)
          quill.setContents(parsedJson)
        } catch (exception) {
          // no need to handle this - just leave the text editor blank
        }
      }

    const form = document.querySelector('form#text');
    form.onsubmit = () => {
      // Populate hidden form on submit
      const htmlInput = document.querySelector('input[id=html]');
      htmlInput.value = quill.root.innerHTML;

      const deltaInput = document.querySelector('input[id=deltas]');
      deltaInput.value = JSON.stringify(quill.getContents());
      
      return true;
    };
}