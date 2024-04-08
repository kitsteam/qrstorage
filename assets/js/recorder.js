import Amplitude from 'amplitudejs/dist/amplitude';
import ProgressCircle from './progress_circle';
import { MediaRecorder, register } from 'extendable-media-recorder';
import { connect } from 'extendable-media-recorder-wav-encoder';
import { encodeWavAsMp3 } from './audio/mp3';

const recorder = document.querySelector("#recorder");

if (recorder) {
  const deleteButton = document.getElementById('recorder-button-delete');
  const audioFileInput = document.getElementById('recording_audio_file');
  const audioFileTypeInput = document.getElementById('recording_audio_file_type');
  const recordStartStopButton = document.getElementById("recorder-button-start-stop");
  const playButton = document.getElementById('play');
  const formSubmitButton = document.querySelector('.recording button[type=submit]');

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
        setupMediaDevice();
      } else {
        console.debug("navigator.mediaDevices.getUserMedia not supported on your browser!");
        disableRecordingForm();
      }

      tabBarRecordingButton.removeEventListener('click', initialSetup);
    }

    tabBarRecordingButton.addEventListener('click', initialSetup);
  }

  const setupMediaDevice = async () => {
    // this connects the wav extension:
    const port = await connect();
    await register(port);

    // force stereo:
    const constraints = {audio: {channelCount: 2}}

    let onSuccess = function (stream) {
      setupMediaRecorder(stream);
    };

    let onError = function (err) {
      console.error("Error occured while loading media device: " + err);
      disableRecordingForm();
    };

    navigator.mediaDevices.getUserMedia(constraints).then(onSuccess, onError);
  }

  const setupMediaRecorder = (stream) => {
    const options = { mimeType: selectMimeType() };

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
      console.debug("File size: " + blob.size / 1024);

      chunks = [];

      blob.arrayBuffer().then((buffer) => {
        const mp3Blob = encodeWavAsMp3(buffer);

        uploadMp3(mediaRecorder, mp3Blob);
        enablePlayback(mp3Blob);
        // don't enable form submit until encoding is done:
        formSubmitButton.disabled = false;
      })



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
    audioFileInput.value = '';
    audioFileTypeInput.value = '';
    durationStartTime = new Date().getTime();
    updateProgressCircle(0);
    enableRecording();
  }

  const selectMimeType = () => {
    const wav = 'audio/wav';
    if (MediaRecorder.isTypeSupported(wav)) {
      return wav;
    }
    else {
      console.error('Audio format is not supported on this browser!');
      return '';
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

  const enablePlayback = (mp3Blob) => {
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

    const audioUrl = URL.createObjectURL(mp3Blob);
    // start amplitude player:
    Amplitude.init({
      "callbacks": {
        timeupdate: updateProgressCircleFromPlayback
      },
      songs: [{ "url": audioUrl }],
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

  const uploadMp3 = (mediaRecorder, mp3Blob) => {
    let file = new File([mp3Blob], "recording", { type: "audio/mp3", lastModified: new Date().getTime() });
    let container = new DataTransfer();
    container.items.add(file);
    audioFileInput.files = container.files;
    audioFileTypeInput.value = mediaRecorder.mimeType;
  }

  const disableRecordingForm = () => {
    // remove existing form:
    const recordingForm = document.querySelector('#recording');
    if (recordingForm) {
      recordingForm.remove();
    }

    // show warning hint:
    const recordingDisabled = document.querySelector('#recording-not-supported');
    if (recordingDisabled) {
      recordingDisabled.classList.remove('d-none');
    }
  }
}
