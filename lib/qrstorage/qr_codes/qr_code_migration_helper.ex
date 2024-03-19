defmodule Qrstorage.QrCodes.QrCodeMigrationHelper do
  @spec add_delete_after_months(Ecto.Repo.t()) :: any()
  def add_delete_after_months(repo) do
    repo.query!(
      "UPDATE qrcodes
SET delete_after_months =
    CASE
        WHEN DATE_TRUNC('hour', delete_after) <= DATE_TRUNC('hour', inserted_at + INTERVAL '1 hour') THEN 0
        WHEN DATE_TRUNC('day', delete_after) <= DATE_TRUNC('day', inserted_at + INTERVAL '1 month') THEN 1
        WHEN DATE_TRUNC('day', delete_after) <= DATE_TRUNC('day', inserted_at + INTERVAL '6 months') THEN 6
        WHEN DATE_TRUNC('day', delete_after) <= DATE_TRUNC('day', inserted_at + INTERVAL '12 months') THEN 12
        ELSE 36
    END;
",
      [],
      log: :info
    )
  end
end
