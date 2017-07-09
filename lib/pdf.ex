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

    clientname = String.replace(client, ~r/[," "&']/, "")
    savefile = Enum.join([clientname, "_", invoicenum, ".pdf"])

    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=#{savefile}")
    |> send_file(200, filename)

    case File.exists?(filename) do
      true -> File.rm(filename)
      _ -> "no file to remove"
    end
  end

end
