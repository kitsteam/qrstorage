import Amplitude from 'amplitudejs/dist/amplitude';
import ProgressCircle from './progress_circle';
import { MediaRecorder, register } from 'extendable-media-recorder';
import { connect } from 'extendable-media-recorder-wav-encoder';
import * as lamejs from 'lamejs/src/js/index';

const recorder = document.querySelector("#recorder");

if (recorder) {
  const deleteButton = document.getElementById('recorder-button-delete');
  const audioFileInput = document.getElementById('recording_audio_file')
  const audioFileTypeInput = document.getElementById('recording_audio_file_type')
  const recordStartStopButton = document.getElementById("recorder-button-start-stop");
  const playButton = document.getElementById('play');
  const formSubmitButton = document.querySelector('.recording button[type=submit]')

  const maximumDuration = 120;
  let durationStartTime = new Date().getTime();

  window.onload = function () {
    ProgressCircle.init();

    // start with an empty circle:
    ProgressCircle.drawProgressCircle(0);

    // redraw on size change:
    window.addEventListener("resize", (event) => {
      ProgressCircle.init();
      // this might resize the circle to the wrong size for a moment, but as soon as the next time the circle is updated this will be fine:
      updateProgressCircle(0);
    });

    const tabBarRecordingButton = document.getElementById("qr_code_content_type_recording");
    const initialSetup = (event) => {
      if (navigator.mediaDevices.getUserMedia) {
        console.debug("navigator.mediaDevices.getUserMedia is supported.");
        setupMediaDevice()
      } else {
        console.debug("navigator.mediaDevices.getUserMedia not supported on your browser!");
        //::TODO:: show error, disable (or don't enable) recording buttons
      }

      tabBarRecordingButton.removeEventListener('click', initialSetup);
    }

    tabBarRecordingButton.addEventListener('click', initialSetup);
  }

  const setupMediaDevice = async () => {
    // this connects the wav extension:
    const port = await connect();
    await register(port);

    const constraints = { audio: true };

    let onSuccess = function (stream) {
      setupMediaRecorder(stream)
    };

    let onError = function (err) {
      console.error("Error occured while loading media device: " + err);
    };

    navigator.mediaDevices.getUserMedia(constraints).then(onSuccess, onError);
  }

  const setupMediaRecorder = (stream) => {
    const options = { mimeType: selectMimeType() }

    const mediaRecorder = new MediaRecorder(stream, options);

    let chunks = [];

    // this is for scaling the circle:
    const analyser = buildAudioAnlyser(stream);

    recordStartStopButton.onclick = function () {
      if (mediaRecorder.state === 'recording') {
        // stop if running:
        stopRecording(mediaRecorder);
      }
      else {
        // start if not running:
        startRecording(mediaRecorder, analyser);
      }
    };

    mediaRecorder.onstop = function (e) {
      const blob = new Blob(chunks, { type: mediaRecorder.mimeType });
      const audioURL = URL.createObjectURL(blob);
      console.debug("File size: " + blob.size / 1024);

      chunks = [];

      blob.arrayBuffer().then((buffer) => {

        var wav = lamejs.WavHeader.readHeader(new DataView(buffer));
        var samples = new Int16Array(buffer, wav.dataOffset, wav.dataLen / 2);

        const mp3Blob = encodeMono(wav.channels, wav.sampleRate, samples);

        let file = new File([mp3Blob], "recording", { type: "audio/mp3", lastModified: new Date().getTime() });
        let container = new DataTransfer();
        container.items.add(file);
        audioFileInput.files = container.files;
        audioFileTypeInput.value = mediaRecorder.mimeType;

        // don't enable form submit until encoding is done:
        formSubmitButton.disabled = false;
      })

      enablePlayback(audioURL);

      deleteButton.onclick = function (e) {
        deleteRecording();
      };
    };

    mediaRecorder.ondataavailable = function (e) {
      chunks.push(e.data);
    };
  }

  const deleteRecording = () => {
    // remove recorded content:
    audioFileInput.value = ''
    audioFileTypeInput.value = '';
    durationStartTime = new Date().getTime();
    updateProgressCircle(0);
    enableRecording();
  }

  const selectMimeType = () => {
    const wav = 'audio/wav'
    if (MediaRecorder.isTypeSupported(wav)) {
      return wav
    }
    else {
      // ::TODO:: error!
      return ''
    }
  }

  const updateProgressCircle = (elapsedSeconds) => {
    if (isNaN(elapsedSeconds)) {
      elapsedSeconds = elapsedSeconds;
    }

    const percentage = elapsedSeconds / maximumDuration * 100;
    ProgressCircle.drawProgressCircle(percentage);
  };


  const stopRecording = (mediaRecorder) => {
    mediaRecorder.stop();
    recordStartStopButton.classList.remove('running');
    updateProgressCircle(0);
  }

  const startRecording = (mediaRecorder, analyser) => {
    mediaRecorder.start();
    recordStartStopButton.classList.add('running');
    formSubmitButton.disabled = true;
    deleteRecording();
    scaleCircle(mediaRecorder, analyser);
    durationStartTime = new Date().getTime();

    const updateProgressCircleTimer = () => {
      if (mediaRecorder.state === 'recording') {
        const currentTime = new Date().getTime();
        const elapsedMilliseconds = currentTime - durationStartTime;
        const elapsedSeconds = elapsedMilliseconds / 1000;

        if (elapsedSeconds > maximumDuration) {
          stopRecording(mediaRecorder);
        }
        updateProgressCircle(elapsedSeconds);

        setTimeout(updateProgressCircleTimer, 100);
      }
    }

    updateProgressCircleTimer()
  }

  const scaleCircle = (mediaRecorder, analyser) => {
    if (mediaRecorder.state !== 'recording') {
      // scale back to default and stop:
      recordStartStopButton.style.transform = `scale(1)`;
      return;
    }

    const dataArray = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteFrequencyData(dataArray);

    // Use the maximum value in the frequency data array as the instantaneous volume
    const instantaneousVolume = Math.max(...dataArray);

    // Scale the circle based on the instantaneous volume
    const scaleValue = 1 + instantaneousVolume / 256; // 128 is the maximum value, we don't want to double the circle, max should be a 1.5 increase
    recordStartStopButton.style.transform = `scale(${scaleValue})`;

    requestAnimationFrame(() => {
      scaleCircle(mediaRecorder, analyser);
    });
  };

  const enablePlayback = (dataUrl) => {
    const updateProgressCircleFromPlayback = () => {
      let percentage = Amplitude.getSongPlayedPercentage();

      if (isNaN(percentage)) {
        percentage = 0;
      }
      ProgressCircle.drawProgressCircle(percentage);
    };

    // switch play/pause buttons:
    playButton.classList.remove('d-none');
    deleteButton.classList.remove('d-none');
    recordStartStopButton.classList.add('d-none');

    // start amplitude player:
    Amplitude.init({
      "callbacks": {
        timeupdate: updateProgressCircleFromPlayback
      },
      songs: [{ "url": dataUrl }],
      playback_speed: 1.0
    });
  }

  const enableRecording = () => {
    recordStartStopButton.classList.remove('d-none');
    deleteButton.classList.add('d-none');
    playButton.classList.add('d-none');
  }

  const buildAudioAnlyser = (stream) => {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const analyser = audioContext.createAnalyser();
    const microphone = audioContext.createMediaStreamSource(stream);
    microphone.connect(analyser);
    return analyser;
  }
}

function encodeMono(channels, sampleRate, samples) {
  // from the following example: https://github.com/zhuker/lamejs/blob/582bbba6a12f981b984d8fb9e1874499fed85675/example.html#L6
  var buffer = [];
  var mp3enc = new lamejs.Mp3Encoder(channels, sampleRate, 128);
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

  var blob = new Blob(buffer, { type: 'audio/mp3' });

  return blob
}