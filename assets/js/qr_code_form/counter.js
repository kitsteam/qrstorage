const containerIds = ["#link", "#audio"];

containerIds.forEach(function(containerId) {
  const textContainer = document.querySelector(containerId + " textarea")
  const characterCounterContainer = document.querySelector(containerId + " .character-counter");

  if (textContainer) {
    textContainer.addEventListener('input', function() {
      // handle character counter:
      var textLength = textContainer.textLength
      const maxCharacters = textContainer.getAttribute('maxlength');
      const charactersLeft = maxCharacters - textLength

      characterCounterContainer.innerText = charactersLeft;

    }, false);
  }
})