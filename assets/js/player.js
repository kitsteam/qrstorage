import Amplitude from 'amplitudejs/dist/amplitude';

const player = document.querySelector("#player");

if (player) {

    window.onload = function() {

        const dataUrl = player.getAttribute("data-url");

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
        const lineWidth = 30;
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
            drawCircle(ctx, '#00456f', radius, lineWidth, percentage / 100);
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
            ],
            playback_speed: 1.0
        });
    
        const skipBackButton = document.getElementById("skip-back");
    
        skipBackButton.addEventListener('click', (event) => {
            const seconds = Amplitude.getSongPlayedSeconds();
            const skipBackSeconds = skipBackButton.getAttribute("data-skip-back-seconds");
            Amplitude.skipTo(Math.max(0, seconds - skipBackSeconds), 0);
        })
    
    
        const playbackSpeedButton = document.getElementById("playback-speed");
    
        const changePlaybackSpeed = (button, speed) => {
            Amplitude.setPlaybackSpeed(speed);
            button.setAttribute("data-playback-speed", speed);
            button.innerHTML = speed+"x";
        }
    
        playbackSpeedButton.addEventListener('click', (event) => {
            const currentPlaybackSpeed = playbackSpeedButton.getAttribute("data-playback-speed");
            const slow = 0.5;
            const normal = 1.0;
    
            if (currentPlaybackSpeed == normal) {
                changePlaybackSpeed(playbackSpeedButton, slow);
            }
            else {
                changePlaybackSpeed(playbackSpeedButton, normal);
            }
        })
    
        // start with an empty circle:
        drawProgressCircle(0);
    }
}