defmodule Qrstorage.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Qrstorage.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Qrstorage.Repo
      alias Qrstorage.QrCodes

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Qrstorage.DataCase

      def qr_code_count() do
        Qrstorage.Repo.one(from code in Qrstorage.QrCodes.QrCode, select: count("1"))
      end

      @valid_attrs %{
        delete_after_months: 1,
        text: "some text",
        hide_text: false,
        content_type: "text",
        language: nil,
        hp: nil,
        deltas: %{"id" => "test"},
        dots_type: "dots"
      }

      @valid_audio_attrs %{
        delete_after_months: 1,
        text: "text",
        content_type: "audio",
        language: "de",
        dots_type: "dots",
        voice: "female"
      }

      def qr_code_fixture(attrs \\ %{}) do
        {:ok, qr_code} =
          attrs
          |> Enum.into(@valid_attrs)
          |> QrCodes.create_qr_code()

        qr_code
      end

      def audio_qr_code_fixture(attrs \\ %{}) do
        {:ok, qr_code} =
          attrs
          |> Enum.into(@valid_audio_attrs)
          |> QrCodes.create_qr_code()

        qr_code
      end

      def overdue_qr_code(attrs \\ %{}) do
        attrs = Map.merge(@valid_attrs, attrs)
        qr_code = qr_code_fixture(attrs)
        last_access_date = Timex.shift(Timex.now(), months: -7)
        Repo.update!(Ecto.Changeset.cast(qr_code, %{last_accessed_at: last_access_date}, [:last_accessed_at]))
        qr_code
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Qrstorage.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Qrstorage.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
