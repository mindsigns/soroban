defmodule Soroban.BatchController do
  use Soroban.Web, :controller

  import Soroban.Authorize
  import Ecto.Query

  alias Soroban.{Repo, Invoice, Client}
  alias Soroban.{InvoiceUtils, Pdf}

  plug :user_check 

  plug :load_clients when action in [:index, :generate] 

  @doc"""
  Index function
  """
  def index(conn, _params) do
    today = Date.utc_today()

    render(conn, "index.html", today: today, text: "")
  end

  @doc"""
  Deletes invoices by the Invoice Number
  """
  def delete(conn, %{"id" => id}) do
    query = (from i in Invoice,
      where: i.number == ^id)

    Repo.delete_all(query)

    conn
    |> put_flash(:info, "Invoice deleted successfully.")
    |> redirect(to: invoice_path(conn, :index))
  end

  @doc"""
  Generate an invoice
  """
  #  def generate(conn, %{"invoice_id" => id}) do
  #
  #  InvoiceUtils.generate(id)
  #
  #  conn
  #  |> put_flash(:info, "Invoice generated successfully.")
  #  |> redirect(to: invoice_path(conn, :index))
  #end

  @doc"""
  Generate a batch of invoices
  """
  def generate_all(conn, params) do
    clients = Repo.all from c in Client, select: c.id

    Task.async(InvoiceUtils, :batch_job, [conn, clients, params])

    conn
      |> put_flash(:info, "Generating all invoices, this will take a bit.")
      |> redirect(to: invoice_path(conn, :index))
  end

  @doc"""
  Email all invoices for a given invoice ID
  """
  def email_all(conn, %{"invoice" => invoice}) do
  query = (from i in Invoice,
            where: i.number == ^invoice,
            select: i.id)

  invoice_ids = Repo.all(query)

  InvoiceUtils.batch_email(invoice_ids)

  case Enum.count(Slingbag.show) do
    0 ->  Slingbag.empty
          conn
            |> put_flash(:info, "Emailing all invoices.")
            |> redirect(to: invoice_path(conn, :index))
    _ ->  
          msg = Enum.join(["Warning : Emails for ", Slingbag.show, " not sent. No email addresses available for them."], " ")
          Slingbag.empty
          conn
            |> put_flash(:info, "Emailing all invoices.")
            |> put_flash(:error, msg)
            |> redirect(to: invoice_path(conn, :index))
  end
end

  @doc"""
  Builds and sends a zip file of all PDF invoices with the same Invoice ID
  """
  def send_zip(conn, %{"invoice" => invoice}) do

  query = (from i in Invoice,
            where: i.number == ^invoice,
            join: p in assoc(i, :client),
            select: p.name)

  client_list = Repo.all(query)

  Pdf.batch_zip(conn, invoice, client_list)
  end

  #
  # Private functions
  #

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

end
