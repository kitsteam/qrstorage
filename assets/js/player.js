import Amplitude from 'amplitudejs/dist/amplitude';

const dataUrl = document.querySelector("#player").getAttribute("data-url");

// based on https://github.com/rendro/easy-pie-chart
const drawCircle = (ctx, color, radius, lineWidth, percent) => {
    percent = Math.min(Math.max(0, percent || 1), 1);
    ctx.beginPath();
    ctx.arc(0, 0, radius, 0, Math.PI * 2 * percent, false);
    ctx.strokeStyle = color;
    ctx.lineCap = 'round';
    ctx.lineWidth = lineWidth;
    ctx.stroke();
};

// settings for circle:
const progressbar = document.getElementById('progressbar');
const size = progressbar.offsetWidth;
const lineWidth = 20;
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');

// increase the size of the canvas by the devicePixelRatio to make sure it's sharp:
canvas.width = canvas.height = size * window.devicePixelRatio;
// the canvas element must have the original size: (i.e. we'll put a larger canvas into a smaller element)
canvas.style.height = canvas.style.width = size + "px";

const radius = (canvas.width - lineWidth) / 2;

// append canvas:
progressbar.appendChild(canvas);

// set translation to move circle to center:
ctx.translate(canvas.width / 2, canvas.width / 2);
ctx.rotate((-1 / 2) * Math.PI);
const translation = -1 * canvas.width / 2;

const drawProgressCircle = (percentage) => {
    if (percentage == 0) {
        percentage = 0.1;
    }

    // clear for redraw:
    ctx.clearRect(translation, translation, canvas.width, canvas.height);

    // redraw:
    drawCircle(ctx, '#efefef', radius, lineWidth, 100 / 100);
    drawCircle(ctx, 'rgb(0, 69, 111)', radius, lineWidth, percentage / 100);
}


// start amplitude player:
Amplitude.init({
    "callbacks": {
        timeupdate: function(){
            let percentage = Amplitude.getSongPlayedPercentage();

            if( isNaN( percentage ) ){
                percentage = 0;
            }
            drawProgressCircle(percentage);
        }
    },
    songs: [
        {
            "url": dataUrl
        }
    ]
});

// start with an empty circle:
drawProgressCircle(0);