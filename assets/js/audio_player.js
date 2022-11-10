// In current Safari versions, there is a short delay when replaying audio files. 
// This results in the beginning of the audio clip being cut off. 
// As a fix, we can create the AudioContext to capture the audio and keep the site active:
if (window.AudioContext) {
    const audioContext = new window.AudioContext();
}
