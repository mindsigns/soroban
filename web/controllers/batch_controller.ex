defmodule Soroban.BatchController do
  @moduledoc """
  Batch controller used for batch operations
  """
  use Soroban.Web, :controller

  import Soroban.Authorize
  import Ecto.Query

  alias Soroban.{Repo, Invoice, Client}
  alias Soroban.{InvoiceUtils, Pdf}

  plug :user_check

  plug :load_clients when action in [:index, :generate]

  plug :scrub_params, "id" when action in [:delete]
  plug :scrub_params, "invoice" when action in [:send_zip, :email_all]

  @doc """
  Index function
  Route: GET /invoice/batch
  """
  def index(conn, _params) do
    today = Date.utc_today()

    #render(conn, "index.html", today: today, text: "")
    render(conn, "index.html", today: today, text: "", bar_width: 0, progress_bar_class: "",
      long_process_button_text: "Click me to start processing ...")
  end

  @doc """
  Deletes invoices by the Invoice Number
  Route: GET /invoice/delete/<id>
  """
  def delete(conn, %{"id" => id}) do
    query = (from i in Invoice,
      where: i.number == ^id)

    Repo.delete_all(query)

    path = Enum.join([Soroban.Pdf.pdf_path(), id, "*.pdf"])
    files = Path.wildcard(path)

    for f <- files do
    File.rm(f)
    end

    conn
    |> put_flash(:info, "Invoice deleted successfully.")
    |> redirect(to: invoice_path(conn, :index))
  end

  @doc """
  Generate a batch of invoices based on date ranges
  Route: POST /invoice/generate_all
  """
  def generate_all(conn, params) do
    clients = Repo.all from c in Client, select: c.id

    Task.async(InvoiceUtils, :batch_job, [conn, clients, params])

    conn
      |> put_flash(:info, "Generating all invoices, this will take a bit.")
      |> redirect(to: invoice_path(conn, :index))
  end

  @doc """
  Email all invoices for a given invoice ID
  Route: GET /invoice/email_all/<invoice_id>
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

  @doc """
  Builds and sends a zip file of all PDF invoices with the same Invoice ID
  Route: GET /invoice/sendzip/<invoice_id>
  """
  def send_zip(conn, %{"invoice" => invoice}) do
    query = (from i in Invoice,
                  where: i.number == ^invoice,
                  join: p in assoc(i, :client),
                  select: %{client: p.name, inv_id: i.id})

    client_list = Repo.all(query)

    Pdf.batch_zip(conn, invoice, client_list)
  end

  #
  # Private functions
  #

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, order_by: c.name, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

end
