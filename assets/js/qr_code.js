import QRCodeStyling from "qr-code-styling";

const qrCodeOptions = (color, url, width, height) => (
     {
        width: width,
        height: height,
        type: "svg",
        data: url,
        image: "",
        dotsOptions: {
            color: color,
            type: "dots",
        },
        cornersSquareOptions: {
            type: 'square'
        },
        cornersDotOptions: {
            type: 'dot'
        },
        backgroundOptions: {
            color: "#fff",
        },
        imageOptions: {
            crossOrigin: "anonymous",
            margin: 20,
        },    
    }
)

const createQrCode = (canvas, color, url, width, height) => {
    const qrCode = new QRCodeStyling(qrCodeOptions(color, url, width, height));
    qrCode.append(canvas);

    return qrCode   
}

// show qr code after saving:
const canvas = document.getElementById("canvas");

if (canvas) {
  const url = canvas.getAttribute("data-url");
  const color = canvas.getAttribute("data-color");
  const width = 300;
  const height = 300;
  const qrCode = createQrCode(canvas, color, url, width, height);

  document.getElementById("btn-qr-download").addEventListener('click', () => qrCode.download({ name: "qr", extension: "png" }));
}