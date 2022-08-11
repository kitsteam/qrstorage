const voiceHelp =  document.getElementById('voice-help');

const toggleVoiceSwitch = (language) => {

    const languagesWithMaleVoice = voiceHelp.dataset.languagesWithMaleVoice;
    const voiceSwitch = document.getElementById('audio_voice');

    // hide hint and enable button for languages that support male voice:
    if (languagesWithMaleVoice.includes(language)) {
        voiceSwitch.removeAttribute("disabled");
        voiceHelp.classList.add("d-none");
    }
    else {
        voiceSwitch.disabled = "disabled";
        voiceSwitch.checked = false;
        voiceHelp.classList.remove("d-none");
    }
}

if (voiceHelp) {

    const languageSelect = document.getElementById('audio_language');
    const language = languageSelect.value;

    toggleVoiceSwitch(language);

    languageSelect.addEventListener('change', (event) => { 
        toggleVoiceSwitch(languageSelect.value);
    });
}