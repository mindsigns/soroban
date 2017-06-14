defmodule Soroban.InvoiceController do
  use Soroban.Web, :controller

  import Soroban.Authorize
  import Money

  alias Soroban.Invoice
  alias Soroban.Job
  alias Soroban.Client


  plug :user_check when action in [:index, :update, :delete, :show]
  plug :load_clients when action in [:index, :new, :create, :edit, :show, :update, :generate] 

  def index(conn, _params) do
    invoices = Repo.all(Invoice)|> Repo.preload(:client)
    render(conn, "index.html", invoices: invoices)
  end

  def generate(conn, %{"invoice_id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)

    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    totalquery = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              select: j.total)


    jobs = Repo.all(query) |> Repo.preload(:client)
    jobtotals = Repo.all(totalquery)

  ltotal = for n <- jobtotals, do: Map.get(n, :amount)
  total = Money.new(Enum.sum(ltotal))

    changeset = Ecto.Changeset.change(invoice, %{total: total})
    Repo.update!(changeset)

  Soroban.Email.invoice_html_email("test@test.com", invoice, jobs, total) |> Soroban.Mailer.deliver_now

    render(conn, "generate.html", invoice: invoice, jobs: jobs, total: total)

  end

  def new(conn, _params) do
    changeset = Invoice.changeset(%Invoice{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    changeset = Invoice.changeset(%Invoice{}, invoice_params)

    case Repo.insert(changeset) do
      {:ok, _invoice} ->
        conn
        |> put_flash(:info, "Invoice created successfully.")
        |> redirect(to: invoice_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)
    render(conn, "show.html", invoice: invoice)
  end

  def edit(conn, %{"id" => id}) do
    #invoice = Repo.get!(Invoice, id)
    invoice = Repo.get!(Invoice, id)|> Repo.preload(:client)
    changeset = Invoice.changeset(invoice)
    render(conn, "edit.html", invoice: invoice, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invoice" => invoice_params}) do
    invoice = Repo.get!(Invoice, id)
    changeset = Invoice.changeset(invoice, invoice_params)

    case Repo.update(changeset) do
      {:ok, invoice} ->
        conn
        |> put_flash(:info, "Invoice updated successfully.")
        |> redirect(to: invoice_path(conn, :show, invoice))
      {:error, changeset} ->
        render(conn, "edit.html", invoice: invoice, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(invoice)

    conn
    |> put_flash(:info, "Invoice deleted successfully.")
    |> redirect(to: invoice_path(conn, :index))
  end

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

end
