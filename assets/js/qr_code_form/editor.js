import Quill from 'quill'

Quill.register('modules/counter', function(quill, options) {
    var container = document.querySelector(options.container);
    quill.on('text-change', function() {
      var text = quill.getText();
      const maxCharacters = container.getAttribute('data-max-characters');
      const charactersLeft = maxCharacters - text.length

      container.innerText = charactersLeft;
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