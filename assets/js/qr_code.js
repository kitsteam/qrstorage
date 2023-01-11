import QRCodeStyling from "qr-code-styling";

const qrCodeOptions = (color, url, dots_type, width, height) => (
     {
        width: width,
        height: height,
        type: "svg",
        data: url,
        image: "",
        dotsOptions: {
            color: color,
            type: dots_type,
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

const createQrCode = (canvas, color, url, dots_type, width, height) => {
    const qrCode = new QRCodeStyling(qrCodeOptions(color, url, dots_type, width, height));
    qrCode.append(canvas);

    return qrCode   
}

// show qr code after saving:
const canvas = document.getElementById("canvas");

if (canvas) {
  const url = canvas.getAttribute("data-url");
  const color = canvas.getAttribute("data-color");
  const dots_type = canvas.getAttribute("data-dots-type");
  const width = (document.getElementById("content").offsetWidth <= 400) ? document.getElementById("content").offsetWidth - 28 : 372;
  const height = width;
  const qrCode = createQrCode(canvas, color, url, dots_type, width, height);

  document.querySelectorAll("#qr-download-dropdown-menu .dropdown-item").forEach((dropdownItem) => {
    dropdownItem.addEventListener('click', (e) => { 
        qrCode.download({ name: "qr", extension: dropdownItem.dataset.fileType });
        e.preventDefault();
        e.stopPropagation();
        return false;
    });
  });
}