defmodule Soroban.Pdf do
  @moduledoc """
  PDF helper functions
  """

  use Bamboo.Phoenix, view: Soroban.EmailView

  import Plug.Conn

  alias Soroban.{Repo, Invoice, InvoiceUtils}

  @doc """
  Generates PDF from HTML and saves to the filesystem if PDF file does not
  already exist in cache.
  """
  def to_pdf(invoice, jobs, total, company) do

    savefile = create_file_name(invoice.client.name, invoice.number)
    newfile = Enum.join([pdf_path(), savefile])

    case File.exists?(newfile) do
       true  -> "File exists"
       false -> html = Phoenix.View.render_to_string(Soroban.LayoutView, "invoice.html",
							invoice: invoice, jobs: jobs, total: total, company: company)
                pdf_binary = PdfGenerator.generate_binary!(html, delete_temporary: true)
                File.write(newfile, pdf_binary)
    end
  end

  @doc """
  Build the filename from Invoice info and send the PDF to the client
  """
  def send_pdf(conn, id) do

    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)

    savefile = create_file_name(invoice.client.name, invoice.number)
    newfile = Enum.join([pdf_path(), savefile])

    case File.exists?(newfile) do
       true  -> IO.puts "File exists"
       false -> InvoiceUtils.generate(id, true)
    end

    send_a_file(conn, newfile, savefile, "pdf")
  end

  @doc """
  Generate and zip PDF files
  """
  def batch_zip(conn, invoicenum, clients) do

    Slingbag.empty

    pdfpath = String.to_charlist(pdf_path())
    zipfile = Enum.join([pdf_path(), invoicenum, ".zip"])
    savefile = Enum.join([invoicenum, ".zip"])

    # Create a list of file names
    for c <- clients do
      file = String.to_charlist(create_file_name(c[:client], invoicenum))
      Slingbag.add(file)
      case File.exists?(Enum.join([pdfpath, file])) do
        true -> "File exists"
        false -> InvoiceUtils.generate_batch(c[:inv_id], true)
      end
    end

    filenames = Slingbag.show
    Slingbag.empty

    {:ok, {"mem", zipbin}} = :zip.create("mem", filenames,
                                         [:memory, cwd: pdfpath])
    File.write(zipfile, zipbin)
    send_a_file(conn, zipfile, savefile, "zip")
  end

  @doc """
  Returns PDF path from config/config.exs
  """
  def pdf_path do
    Application.app_dir(:soroban, Application.get_env(:soroban, :pdf_dir))
  end

  @doc """
  Creates a filename from Invoice ID and Client name
  """
  def create_file_name(client, invoicenum) do
    clientname = String.replace(client, ~r/[," "&']/, "")
    Enum.join([invoicenum, "_", clientname, ".pdf"])
  end

#
# Private functions
#
  # Sends a file to the browser
  defp send_a_file(conn, filename, savefile, type) do
    conn
      |> put_resp_content_type("application/#{type}")
      |> put_resp_header("content-disposition", "attachment; filename=#{savefile}")
      |> send_file(200, filename)
  end

end
