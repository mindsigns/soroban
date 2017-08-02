defmodule Soroban.InvoiceController do
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.{Invoice, Job, Client, Email, Mailer, Pdf}
  alias Soroban.InvoiceUtils

  plug :user_check 

  plug :load_clients when action in [:index, :new, :create, :edit, :show, :update, :generate] 

  def index(conn, _params) do

    invoices = Invoice
               |> distinct(:number)
               |> Repo.all

    render(conn, "index.html", invoices: invoices)
  end

  def generate_pdf(conn, %{"invoice_id" => id}) do

    {invoice, jobs, _, _} = InvoiceUtils.generate(id, true)

    render(conn, "show.html", invoice: invoice, jobs: jobs)
  end

  def send_pdf(conn, %{"id" => id}) do
    Pdf.send_pdf(conn, id)
  end

  def generate_email(conn, %{"invoice_id" => id}) do

    {invoice, jobs, total, company} = InvoiceUtils.generate(id, true)

    Email.invoice_html_email(invoice.client.email, invoice, jobs, total, company)
      |> Mailer.deliver_later
  
    msg = Enum.join(["Invoice mailed to : ", invoice.client.contact, " <", invoice.client.email,">"])
    conn
      |> put_flash(:info, msg)
      |> render("show.html", invoice: invoice, jobs: jobs)
  end

  def new(conn, _params) do
    changeset = Invoice.changeset(%Invoice{})
    today = Date.utc_today()

    render(conn, "new.html", changeset: changeset, today: today)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    changeset = Invoice.changeset(%Invoice{}, invoice_params)

    invtotal = total(Ecto.Changeset.get_field(changeset, :client_id),
                     Ecto.Changeset.get_field(changeset, :start),
                     Ecto.Changeset.get_field(changeset, :end))

    newchangeset = Ecto.Changeset.put_change(changeset, :total, invtotal)

    case Repo.insert(newchangeset) do
      {:ok, _invoice} ->
        conn
        |> put_flash(:info, "Invoice created successfully.")
        |> redirect(to: invoice_path(conn, :index))
      {:error, newchangeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)

    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    render(conn, "show.html", invoice: invoice, jobs: jobs)
  end

  def show_invoice(conn, %{"invoice_id" => id}) do

    query = (from i in Invoice,
              where: i.number == ^id)
    invoices = Repo.all(query) |> Repo.preload(:client)

    itotal = for n <- invoices, do: Map.get(n, :total)
    ftotal = for n <- itotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  

    invoice_count = Enum.count(invoices)
    render(conn, "invoicelist.html", invoices: invoices, invoice_id: id, invoice_count: invoice_count, total: total)
  end

  def edit(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)
    changeset = Invoice.changeset(invoice)
    today = Date.utc_today()

    render(conn, "edit.html", invoice: invoice, changeset: changeset, today: today)
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

  defp total(client, startdate, enddate) do
    query = (from j in Job,
              where: j.date >= ^startdate,
              where: j.date <= ^enddate,
              where: j.client_id == ^client,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  
    total
end

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

end
