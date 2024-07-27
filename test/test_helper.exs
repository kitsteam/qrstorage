ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Qrstorage.Repo, :auto)

# Mock Translation API Service:
Mox.defmock(Qrstorage.Services.Translate.TranslateApiServiceMock,
  for: Qrstorage.Services.Translate.TranslateApiService
)

Application.put_env(:qrstorage, :translate_service, Qrstorage.Services.Translate.TranslateApiServiceMock)

# Mock TTS API Service:
Mox.defmock(Qrstorage.Services.Tts.TextToSpeechApiServiceMock,
  for: Qrstorage.Services.Tts.TextToSpeechApiService
)

Application.put_env(:qrstorage, :text_to_speech_service, Qrstorage.Services.Tts.TextToSpeechApiServiceMock)

# Mock Object Storage Service:
Mox.defmock(Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock,
  for: Qrstorage.Services.ObjectStorage.ObjectStorageService
)

Application.put_env(:qrstorage, :object_storage_service, Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock)
