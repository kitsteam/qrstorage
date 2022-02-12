import Quill from 'quill'

Quill.register('modules/counter', function(quill, options) {
    var container = document.querySelector(options.container);
    quill.on('text-change', function() {
      var text = quill.getText();
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
    var quill = new Quill('#editor-container', {
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
      var tooltip = quill.theme.tooltip;
      var input = tooltip.root.querySelector("input[data-link]");
      input.dataset.link = 'https://kits.blog';
    
      // if deltas are present, load them:
      deltas_json = document.querySelector('#deltas').value
      if (deltas_json) {
        try {
          parsed_json = JSON.parse(deltas_json)
          quill.setContents(JSON.parse(document.querySelector('#deltas').value))
        } catch (exception) {
          // no need to handle this - just leave the text editor blank
        }
      }

    var form = document.querySelector('form#text');
    form.onsubmit = function() {
      // Populate hidden form on submit
      var html_input = document.querySelector('input[id=html]');
      html_input.value = quill.root.innerHTML;

      var delta_input = document.querySelector('input[id=deltas]');
      delta_input.value = JSON.stringify(quill.getContents());
      
      return true;
    };
}