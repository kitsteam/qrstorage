const createColor = (color) => {
    const div = document.createElement('div');
    div.classList.add('color', 'col', `colorpicker-background-color-${color}`);
    div.dataset.color = color;
    div.textContent = '\u00A0';
    return div;
}

const escapedColor = (color) => {
  // this will be filtered server side anyway, but just to be sure that no one injects something client side:
  const validColors = ['black', 'gold', 'darkgreen', 'darkslateblue', 'midnightblue', 'crimson'];

  if (validColors.includes(color)) {
    return color;
  }

  return 'black'
}

const formIdSelector = (colorPicker) => {
    return "#"+colorPicker.dataset.formId;
}

const defaultColor = (colorPicker) => {
    // get default color from select field. when the form returns with an error, this field contains the latest color
    const selectField = document.querySelector(formIdSelector(colorPicker) + " > select[name='qr_code[color]']");

    if (selectField) {
        const existingColor = selectField.value;

        if (existingColor) {
            const existingColorElement = colorPicker.querySelector(":scope > .color[data-color="+existingColor+"]");
            return existingColorElement;
        }
    }
    
    const defaultColorElement = colorPicker.querySelector(':scope > .color:first-child');
    return defaultColorElement;
}

const selectColor = (colorPicker, colorElement) => {
    // set input field to new color:
    document.querySelectorAll(formIdSelector(colorPicker) + " > select[name='qr_code[color]']").forEach((select) => {
        select.value = colorElement.dataset.color;
    });
    
    // remove previous selection:
    const selectedColor = colorPicker.querySelector(":scope > .color-selected");
    
    if (selectedColor) {
        selectedColor.classList.remove("color-selected");
    }
    
    // add new selection:
    colorElement.classList.add('color-selected');
}

// colorpicker
const colorPickers = document.querySelectorAll('.colorpicker');

if (colorPickers.length > 0) {
    
    // create colors - this assumes that the colors are the same for all QR code types and only selects the first:
    const colors = document.querySelector("select[name='qr_code[color]']").options;

    for (let colorPicker of colorPickers) {
        for (let color of colors) {
            colorPicker.appendChild(createColor(escapedColor(color.value)));
        }
        
        // select default color:
        selectColor(colorPicker, defaultColor(colorPicker));
    
        // change color on click:
        colorPicker.querySelectorAll(':scope > .color').forEach((color) => {
            color.addEventListener('click', (event) => { 
                selectColor(colorPicker, color);
            });
        });
    }   
}
