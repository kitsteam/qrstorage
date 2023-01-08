import 'bootstrap/js/dist/alert';
import 'bootstrap/js/dist/button';
import 'bootstrap/js/dist/collapse';
import 'bootstrap/js/dist/dropdown';
import Tooltip from 'bootstrap/js/dist/tooltip';

// activate all tooltips:
const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new Tooltip(tooltipTriggerEl))


// configure link list - on iOS, the navigation bar is dynamic. when it's expanded, 
// the link list would be below the fold or very close to the edge. 
// to handle this, we adjust the size of the column to the inner height of the window
const leftColumn = document.getElementById('left-column');

function setLeftColumnHeight(){
    // only resize in landscape mode:

    // ::TODOO:: check ipad pro 12.9 inch - here, the screen is so wide that it's still in portrait mode 
    
    const isLandscape = window.matchMedia('(orientation: landscape)').matches;

    if (isLandscape) {
        leftColumn.setAttribute("style", "height: "+(window.innerHeight)+"px !important");
    }
}
// change the left column size whenever the window is resized
window.addEventListener("resize", setLeftColumnHeight);

// call initially:
setLeftColumnHeight();