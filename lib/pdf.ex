defmodule Soroban.Pdf do
  @moduledoc """
  PDF helper functions
  """

  use Bamboo.Phoenix, view: Soroban.EmailView

  import Plug.Conn

  alias Soroban.{Repo, Invoice, InvoiceUtils}


  @doc """
  Generates HTML from the Email HTML template

  Returns 
  """
  def to_html(invoice, jobs, total, company) do
    new_email()
      |> put_html_layout({Soroban.LayoutView, "email.html"})
      |> render("invoice.html", invoice: invoice, jobs: jobs, total: total, company: company)
  end

  @doc """
  Generates PDF from HTML and saves to the filesystem if PDF file does not
  already exist in cache.
  """
  def to_pdf(invoice, jobs, total, company) do

    savefile = create_file_name(invoice.client.name, invoice.number)   
    newfile = Enum.join([pdf_path(), savefile])

    case File.exists?(newfile) do
       true  -> IO.puts "File exists"
       false -> html = Map.get(to_html(invoice, jobs, total, company), :html_body)
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
       false -> InvoiceUtils.generate(id)
    end

    send_a_file(conn, newfile, savefile, "pdf")
  end

  @doc """
  Generate and zip PDF files
  """
  def batch_zip(conn, invoicenum, clients) do

    IO.inspect {invoicenum, clients}

    # Create a list of file names
    filenames = for c <- clients, do: String.to_char_list(create_file_name(c, invoicenum))

    send_zip(conn, invoicenum, filenames)
  end

  @doc """
  Sends the zipped PDFs to browser
  """
  def send_zip(conn, invoicenum, filenames) do
    zipfile = String.to_char_list(Enum.join([invoicenum, ".zip"]))
    pdfpath = String.to_char_list(pdf_path())
    zipfile = Enum.join([pdf_path(), invoicenum, ".zip"])
    savefile = Enum.join([invoicenum, ".zip"])
    #{:ok, filename} = :zip.create(zipfile, filenames, [cwd: pdfpath])
    {:ok, {"mem", zipbin}} = :zip.create("mem", filenames, [:memory, cwd: pdfpath])
    File.write(zipfile, zipbin)

    IO.inspect {zipfile, pdfpath}
    
    #send_a_file(conn, filename, filename, "zip")
    conn
      |> put_resp_content_type("application/zip")
      |> put_resp_header("content-disposition", "attachment; filename=#{savefile}")
      |> send_file(200, zipfile)

  end

#
# Private functions
#

#Creates a filename from Invoice ID and Client name
  defp create_file_name(client, invoicenum) do
    clientname = String.replace(client, ~r/[," "&']/, "")
    Enum.join([invoicenum, "_", clientname, ".pdf"])
  end

  # Cleans up after sending a file.  Need to work on this more, we want to cache 
  # large files instead of regenerating them 
  defp clean_up(_conn, filename) do
    case File.exists?(filename) do
      true -> File.rm(filename)
      _ -> "no file to remove"
    end
  end

  # Sends a file to the browser
  defp send_a_file(conn, filename, savefile, type) do
    conn
      |> put_resp_content_type("application/#{type}")
      |> put_resp_header("content-disposition", "attachment; filename=#{savefile}")
      |> send_file(200, filename)
  end

  # Returns PDF path from config/config.exs
  defp pdf_path do
    Application.get_env(:soroban, :pdf_dir)
  end

end
