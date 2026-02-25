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
            margin: 0,
        },    
    }
)

const createQrCode = (canvas, color, url, dots_type, width, height) => {
    const qrCode = new QRCodeStyling(qrCodeOptions(color, url, dots_type, width, height));
    qrCode.append(canvas);

    return qrCode   
}

const calculcateWidth = () => {
    const offsetWidth = document.getElementById("content").offsetWidth;
    // 28 px is the margin to the left - on smaller devices, this centers the code
    return Math.min(450, offsetWidth - 28);
}

// show qr code after saving:
const canvas = document.getElementById("canvas");

if (canvas) {
  const url = canvas.getAttribute("data-url");
  const color = canvas.getAttribute("data-color");
  const dots_type = canvas.getAttribute("data-dots-type");
  const height = width = calculcateWidth();
  const qrCode = createQrCode(canvas, color, url, dots_type, width, height);

  document.querySelectorAll("#qr-download-dropdown-menu .dropdown-item").forEach((dropdownItem) => {
    dropdownItem.addEventListener('click', (e) => { 
        qrCode.download({ name: "qr", extension: dropdownItem.dataset.fileType });
        e.preventDefault();
        e.stopPropagation();
        return false;
    });
  });

  // redraw on size change:
  window.addEventListener("resize", (event) => {
    const height = width = calculcateWidth();
    
    canvas.innerHTML = '';

    const qrCode = createQrCode(canvas, color, url, dots_type, width, height);
  });
}