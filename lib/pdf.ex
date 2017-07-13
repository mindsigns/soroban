defmodule Soroban.Pdf do
  use Bamboo.Phoenix, view: Soroban.EmailView
  import Plug.Conn

  def invoice_html_pdf(invoice, jobs, total, company) do
    new_email()
    |> put_html_layout({Soroban.LayoutView, "email.html"})
    |> render("invoice.html", invoice: invoice, jobs: jobs, total: total, company: company)
  end

  def invoice_send_pdf(conn, html, client, invoicenum) do
    {:ok, filename} = PdfGenerator.generate(html, delete_temporary: true)

    savefile = create_file_name(client, invoicenum)   
  
    send_a_file(conn, filename, savefile)
  end

  def invoice_batch_zip(html, invoicenum, client) do
    {:ok, filename} = PdfGenerator.generate(html, delete_temporary: true)
    savefile = create_file_name(client, invoicenum)   
    File.rename(filename, Enum.join(["/home/jon/src/Elixir/soroban/priv/static/pdf/", savefile]))
    Slingbag.add_filename(String.to_char_list(savefile))
  end

  def invoice_send_zip(conn, invoicenum) do
    #files = Slingbag.filenames
    zipfilename = Enum.join([invoicenum, ".zip"])
    {:ok, filename} = :zip.create(zipfilename, Slingbag.filenames, [cwd: '/home/jon/src/Elixir/soroban/priv/static/pdf'])
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
    file_to_del = Enum.join(["/home/jon/src/Elixir/soroban/priv/static/pdf/", filename])
    case File.exists?(file_to_del) do
      true -> File.rm(file_to_del)
      _ -> "no file to remove"
    end
  end

  defp send_a_file(conn, filename, savefile) do
    conn
      |> put_resp_content_type("application/pdf")
      |> put_resp_header("content-disposition", "attachment; filename=#{savefile}")
      |> send_resp(200, filename)
      |> clean_up(filename)
  end

end
