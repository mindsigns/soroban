defmodule Soroban.Utils do
  @moduledoc """
  Utilities
  """

  import Ecto.Query
  alias Soroban.{Repo, Setting}

  @doc """
  Returns a file count of Zip and PDF files currently in the cache directory.
  """
  def cache_count() do
    zipfiles = Path.wildcard(Enum.join([Soroban.Pdf.pdf_path(), "*.zip"]))
    pdffiles = Path.wildcard(Enum.join([Soroban.Pdf.pdf_path(), "*.pdf"]))

    {Enum.count(zipfiles), Enum.count(pdffiles)}
  end

  @doc """
  Returns the email address in Settings
  """
  def get_sender() do
    Repo.one(from(s in Setting, select: s.company_email, limit: 1))
  end

  def to_atom(id) do
    String.to_atom("#{id}")
  end
end
