// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import QRCodeStyling from "qr-code-styling";
import 'bootstrap';

const canvas = document.getElementById("canvas");

if (canvas) {
  const url = canvas.getAttribute("data-url");

  const qrCode = new QRCodeStyling({
    width: 300,
    height: 300,
    type: "svg",
    data: url,
    image: "",
    dotsOptions: {
      color: "#00a3d3",
      type: "rounded",
    },
    backgroundOptions: {
      color: "#fff",
    },
    imageOptions: {
      crossOrigin: "anonymous",
      margin: 20,
    },
  });

  qrCode.append(canvas);

  document.getElementById("btn-qr-download").addEventListener('click', () => qrCode.download({ name: "qr", extension: "png" }));

}
