# https://hexdocs.pm/phoenix/releases.html#ecto-migrations-and-custom-commands
defmodule Qrstorage.Release do
  @app :qrstorage

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Reports audio files in the object storage that have no matching qr code in the database.
  Read-only, nothing is deleted. Run with:

      bin/qrstorage eval "Qrstorage.Release.audit_audio_storage()"
  """
  def audit_audio_storage(grace_minutes \\ 60) do
    load_app()
    # only start what we need, not the endpoint or Oban:
    {:ok, _} = Application.ensure_all_started(:hackney)
    {:ok, _} = Application.ensure_all_started(:ex_aws)

    [repo | _] = repos()

    {:ok, result, _} =
      Ecto.Migrator.with_repo(repo, fn _repo -> Qrstorage.Services.StorageAudit.find_orphans(grace_minutes) end)

    case result do
      {:ok, report} ->
        IO.puts(Qrstorage.Services.StorageAudit.format_report(report))
        {:ok, report}

      {:error, reason} ->
        IO.puts("Audio storage audit failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
