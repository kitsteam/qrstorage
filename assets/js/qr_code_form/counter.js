const containerIds = ["#link", "#audio"];

containerIds.forEach((containerId) => {
  const textContainer = document.querySelector(containerId + " textarea");
  const characterCounterContainer = document.querySelector(containerId + " .character-counter");

  if (textContainer) {
    textContainer.addEventListener('input', () => {
      // handle character counter:
      const textLength = textContainer.textLength;
      const maxCharacters = textContainer.getAttribute('maxlength');
      const charactersLeft = maxCharacters - textLength;

      characterCounterContainer.innerText = charactersLeft;

    }, false);
  }
})