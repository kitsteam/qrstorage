ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Qrstorage.Repo, :auto)

# Mock Google API Service:
Mox.defmock(Qrstorage.Services.Gcp.GoogleApiServiceMock,
  for: Qrstorage.Services.Gcp.GoogleApiService
)

Application.put_env(:qrstorage, :google_api_service, Qrstorage.Services.Gcp.GoogleApiServiceMock)

# Mock Object Storage Service:
Mox.defmock(Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock,
  for: Qrstorage.Services.ObjectStorage.ObjectStorageService
)

Application.put_env(:qrstorage, :object_storage_service, Qrstorage.Services.ObjectStorage.ObjectStorageServiceMock)
