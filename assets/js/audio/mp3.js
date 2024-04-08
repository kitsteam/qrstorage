import * as lamejs from 'lamejs/src/js/index';

export const encodeWavAsMp3 = (buffer) => {
  var wav = lamejs.WavHeader.readHeader(new DataView(buffer));
  var samples = new Int16Array(buffer, wav.dataOffset, wav.dataLen / 2);
  const mp3Blob = encodeAsMp3(wav.channels, wav.sampleRate, samples);

  return mp3Blob;
}

const encodeMono = (mp3enc, samples) => {
  var buffer = [];
  var remaining = samples.length;
  var maxSamples = 1152;
  for (var i = 0; remaining >= maxSamples; i += maxSamples) {
    var mono = samples.subarray(i, i + maxSamples);
    var mp3buf = mp3enc.encodeBuffer(mono);
    if (mp3buf.length > 0) {
      buffer.push(new Int8Array(mp3buf));
    }
    remaining -= maxSamples;
  }
  var d = mp3enc.flush();
  if (d.length > 0) {
    buffer.push(new Int8Array(d));
  }

  return buffer
}

const encodeStereo = (mp3enc, samples) => {
  var buffer = [];
  var maxSamples = 1152;

  let leftData = [];
  let rightData = [];

  // every other array entry should be for the left/right channel:
  for (let i = 0; i < samples.length; i += 2) {
    leftData.push(samples[i]);
    rightData.push(samples[i + 1]);
  }

  var leftSamples = new Int16Array(leftData);
  var rightSamples = new Int16Array(rightData);

  var remaining = leftData.length;
  for (var i = 0; remaining >= maxSamples; i += maxSamples) {
    var left = leftSamples.subarray(i, i + maxSamples);
    var right = rightSamples.subarray(i, i + maxSamples);
    var mp3buf = mp3enc.encodeBuffer(left, right);
    if (mp3buf.length > 0) {
      buffer.push(new Int8Array(mp3buf));
    }
    remaining -= maxSamples;
  }
  var d = mp3enc.flush();
  if (d.length > 0) {
    buffer.push(new Int8Array(d));
  }

  return buffer
}


function encodeAsMp3(channels, sampleRate, samples) {
  // based on the following example: https://github.com/zhuker/lamejs/blob/582bbba6a12f981b984d8fb9e1874499fed85675/example.html#L6
  var buffer = [];
  var mp3enc = new lamejs.Mp3Encoder(channels, sampleRate, 128);

  if (channels == 1) {
    console.debug("Encoding mp3 in mono");
    buffer = encodeMono(mp3enc, samples)
  }
  else if (channels == 2) {
    console.debug("Encoding mp3 in stereo");
    buffer = encodeStereo(mp3enc, samples)
  }
  else {
    console.error("Number of channels " + channels + " not supported.");
    return undefined;
  }

  var blob = new Blob(buffer, { type: 'audio/mp3' });

  return blob
}