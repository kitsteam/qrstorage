import Amplitude from 'amplitudejs/dist/amplitude';
import ProgressCircle from './progress_circle';

const player = document.querySelector("#player");

if (player) {

    window.onload = function() {
        ProgressCircle.init();
        const dataUrl = player.getAttribute("data-url");
        
        const updateProgressCircle = () => {
            let percentage = Amplitude.getSongPlayedPercentage();
    
            if( isNaN( percentage ) ){
                percentage = 0;
            }
            ProgressCircle.drawProgressCircle(percentage);
        };
    
        // start amplitude player:
        Amplitude.init({
            "callbacks": {
                timeupdate: updateProgressCircle
            },
            songs: [{"url": dataUrl}],
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
        ProgressCircle.drawProgressCircle(0);

        // redraw on size change:
        window.addEventListener("resize", (event) => {
            ProgressCircle.init();
            updateProgressCircle();
        });
    }
}