ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Qrstorage.Repo, :auto)

Mox.defmock(Qrstorage.Services.Gcp.GoogleApiServiceMock,
  for: Qrstorage.Services.Gcp.GoogleApiService
)

Application.put_env(:qrstorage, :google_api_service, Qrstorage.Services.Gcp.GoogleApiServiceMock)
