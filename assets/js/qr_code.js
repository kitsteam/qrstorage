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

    // these widths are hardcoded (372+28px -> 400, 492+28px -> 520)
    // where 28px is the margin to the left, so we want that on the right side as well if possible
    // 290/372/492px are chosen carefully so that qr-code-styling does not add a margin. 
    // This has been fixed in a newer, unreleased version, see https://github.com/kozakdenys/qr-code-styling/issues/97

    if (offsetWidth <= 400) {
        return 290;
    }
    else if (offsetWidth <= 520) {
        return 372;
    }
    else {
        return 492;
    }
}

// show qr code after saving:
const canvas = document.getElementById("canvas");

if (canvas) {
  const url = canvas.getAttribute("data-url");
  const color = canvas.getAttribute("data-color");
  const dots_type = canvas.getAttribute("data-dots-type");
  const width = calculcateWidth();
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