defmodule Soroban.Pdf do
  @moduledoc """
  PDF helper functions
  """

  use Bamboo.Phoenix, view: Soroban.EmailView
  import Plug.Conn

  def to_html(invoice, jobs, total, company) do
    new_email()
    |> put_html_layout({Soroban.LayoutView, "email.html"})
    |> render("invoice.html", invoice: invoice, jobs: jobs, total: total, company: company)
  end

  def send_pdf(conn, html, client, invoicenum) do
    {:ok, filename} = PdfGenerator.generate(html, delete_temporary: true)

    savefile = create_file_name(client, invoicenum)   
    newfile = Enum.join([pdf_path(), savefile])
    File.rename(filename, newfile)
  
    send_a_file(conn, newfile, savefile)
  end

  def batch_zip(html, invoicenum, client) do
    {:ok, filename} = PdfGenerator.generate(html, delete_temporary: true)
    savefile = create_file_name(client, invoicenum)   
    File.rename(filename, Enum.join([pdf_path(), savefile]))
    Slingbag.add_filename(String.to_char_list(savefile))
  end

  def send_zip(conn, invoicenum) do
    zipfilename = Enum.join([invoicenum, ".zip"])
    pdf_path = String.to_char_list(pdf_path())
    {:ok, filename} = :zip.create(zipfilename, Slingbag.filenames, [cwd: pdf_path])
    send_a_file(conn, filename, filename)
  end

  #
  # Private functions
  #
  defp create_file_name(client, invoicenum) do
    clientname = String.replace(client, ~r/[," "&']/, "")
    Enum.join([invoicenum, "_", clientname, ".pdf"])
  end

  defp clean_up(_conn, filename) do
    case File.exists?(filename) do
      true -> File.rm(filename)
      _ -> "no file to remove"
    end
  end

  defp send_a_file(conn, filename, savefile) do
    conn
      |> put_resp_content_type("application/pdf")
      |> put_resp_header("content-disposition", "attachment; filename=#{savefile}")
      |> send_file(200, filename)
      |> clean_up(filename)
  end

  # Return PDF path from config/config.exs
  defp pdf_path do
    Application.get_env(:soroban, :pdf_dir)
  end

end
