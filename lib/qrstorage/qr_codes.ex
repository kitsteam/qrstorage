defmodule Qrstorage.QrCodes do
  @moduledoc """
  The QrCodes context.
  """

  import Ecto.Query, warn: false
  alias Qrstorage.Repo

  alias Qrstorage.QrCodes.QrCode

  require Logger

  @doc """
  Gets a single qr_code.

  Raises `Ecto.NoResultsError` if the Qr code does not exist.

  ## Examples

      iex> get_qr_code!(123)
      %QrCode{}

      iex> get_qr_code!(456)
      ** (Ecto.NoResultsError)

  """
  def get_qr_code!(id), do: Repo.get!(QrCode, id)

  @doc """
  Gets a single qr_code by admin_url_id

  Raises `Ecto.NoResultsError` if the Qr code does not exist.
  """
  def get_qr_code_by_admin_url_id!(admin_url_id),
    do: Repo.get_by!(QrCode, admin_url_id: admin_url_id)

  @doc """
  Creates a qr_code.

  ## Examples

      iex> create_qr_code(%{field: value})
      {:ok, %QrCode{}}

      iex> create_qr_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_qr_code(attrs \\ %{}) do
    %QrCode{}
    |> QrCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking qr_code changes.

  ## Examples

      iex> change_qr_code(qr_code)
      %Ecto.Changeset{data: %QrCode{}}

  """
  def change_qr_code(%QrCode{} = qr_code, attrs \\ %{}) do
    QrCode.changeset(qr_code, attrs)
  end

  @doc """
  Deletes all qr_codes that passed the due date
  ## Examples
      iex> delete_old_qrcodes
      :ok
  """
  def delete_old_qr_codes() do
    # delete all codes that are older than last access date + delete_after_months
    Repo.delete_all(
      from q in QrCode,
        where: fragment("NOW() > ? + INTERVAL '1 month' * ?", q.last_accessed_at, q.delete_after_months),
        select: [:id, :content_type]
    )
  end

  def delete_qr_code(%QrCode{} = qr_code) do
    Repo.delete(qr_code)
  end

  def update_last_accessed_at(qr_code) do
    Repo.update!(QrCode.changeset_with_upated_last_accessed_at(qr_code))
  end

  def audio_character_count_in_last_hours(hours) do
    # this query SUMs the length of the text of all audio codes within the last ^hour:
    character_count_query =
      from q in QrCode,
        where: q.content_type == :audio and q.inserted_at > ago(^hours, "hour"),
        select: sum(fragment("character_length(?)", q.text))

    case Repo.one!(character_count_query) do
      nil ->
        Logger.warning("Character length for audio characters is nil!")
        0

      result ->
        result
    end
  end
end
