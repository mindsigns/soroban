defmodule Soroban.Utils do
  @moduledoc """
  Utilities
  """

  @doc """
  Returns a file count of Zip and PDF files currently in the cache directory.
  """
  def cache_count() do
    zipfiles = Path.wildcard(Enum.join([Soroban.Pdf.pdf_path, "*.zip"]))
    pdffiles = Path.wildcard(Enum.join([Soroban.Pdf.pdf_path, "*.pdf"]))

    {Enum.count(zipfiles), Enum.count(pdffiles)}
  end

end
