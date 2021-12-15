const createColor = (color) => {
    return '<div class="color col" style="background-color:'+color+'" data-color="'+color+'">&nbsp;</div>';
}

const selectColor = (colorElement) => {
    // set input field to new color:
    document.querySelector('#colors').value = colorElement.dataset.color;

    // remove previous selection:
    const selectedColor = document.querySelector('.color-selected');
    
    if (selectedColor) {
        selectedColor.classList.remove('color-selected');
    }
    
    // add new selection:
    colorElement.classList.add('color-selected');
}

// colorpicker
const colorPicker = document.querySelector('#colorpicker');

if (colorPicker) {
    // create colors:
    const colors = document.querySelectorAll('#colors > option');

    colors.forEach((color) => {  
        colorPicker.innerHTML += createColor(color.value);
        });

    const defaultColor = document.querySelector('.color:first-child')  
    // select default color:
    selectColor(defaultColor);

    // change color on click:
    document.querySelectorAll('.color').forEach((color) => {
        color.addEventListener('click', (event) => {  
            selectColor(color);
        });
    });
    
}
