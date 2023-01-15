const ProgressCircle = (() => {
    let ctx;
    let translation;
    let canvas;
    let radius;
    const lineWidth = 30;
    
    const init = () => {
        // settings for circle:
        const progressbar = document.getElementById('progressbar');
        const size = progressbar.offsetWidth;

        canvas = document.createElement('canvas');
        ctx = canvas.getContext('2d');
    
        // increase the size of the canvas by the devicePixelRatio to make sure it's sharp:
        canvas.width = canvas.height = size * window.devicePixelRatio;
        // the canvas element must have the original size: (i.e. we'll put a larger canvas into a smaller element)
        canvas.style.height = canvas.style.width = size + "px";
    
        radius = (canvas.width - lineWidth) / 2;
    
        // append canvas:
        progressbar.replaceChildren(canvas);
    
        // set translation to move circle to center:
        ctx.translate(canvas.width / 2, canvas.width / 2);
        ctx.rotate((-1 / 2) * Math.PI);
        translation = -1 * canvas.width / 2;
    }

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

    return { init: init, drawProgressCircle: drawProgressCircle };
})();

export default ProgressCircle;