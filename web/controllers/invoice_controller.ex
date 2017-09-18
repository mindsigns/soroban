defmodule Soroban.InvoiceController do
  @moduledoc """
  Invoice Controller Route: /invoices
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.{Invoice, Job, Client, Email, Mailer, Pdf}
  alias Soroban.InvoiceUtils

  plug :user_check

  plug :load_clients when action in [:index, :new, :create, :edit, :show, :update, :generate]

  plug :scrub_params, "id" when action in [:send_pdf, :show, :edit, :update, :delete, :view]
  plug :scrub_params, "invoice_id" when action in [:send_email, :show_invoice]
  plug :scrub_params, "invoice" when action in [:create]
  plug :scrub_params, "type" when action in [:clear_cache]

  @doc """
  Route: GET /invoices
  Shows a list of Invoices by unique invoice IDs.
  """
  def index(conn, _params) do

    invoices = Invoice
               |> distinct(:number)
               |> Repo.all

    render(conn, "index.html", invoices: invoices)
  end

  @doc """
  Route: GET /invoices/sendpdf/<id>
  Sends a pdf to the browser.
  """
  def send_pdf(conn, %{"id" => id}) do
    Pdf.send_pdf(conn, id)
  end

  @doc """
  Route: GET /invoices/<id>/send_email
  Sends an email to the client email address.
  """
  def send_email(conn, %{"invoice_id" => id}) do

    {invoice, jobs, total, company} = InvoiceUtils.generate(id, true)

    Email.invoice_html_email(invoice.client.email, invoice, jobs, total, company)
      |> Mailer.deliver_later

    msg = Enum.join(["Invoice mailed to : ", invoice.client.contact, " <", invoice.client.email, ">"])
    conn
      |> put_flash(:info, msg)
      |> render("show.html", invoice: invoice, jobs: jobs)
  end

  @doc """
  Route: GET /invoices/new
  Creates a new invoice
  """
  def new(conn, _params) do
    changeset = Invoice.changeset(%Invoice{})
    today = Date.utc_today()

    render(conn, "new.html", changeset: changeset, today: today)
  end

  @doc """
  Route: POST /invoices/
  Inserts data into the database
  """
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

  @doc """
  Route: GET /invoices/<id>
  Displays a single invoice
  """
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

  @doc """
  Route: GET /invoices/<invoice_id>/show
  Displays a list of invoices with the same Invoice ID
  """
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

  @doc """
  Route: GET /invoices/view/<invoice_id_number>
  Shows the HTML version of the rendered invoice using the Email/PDF template.
  """
  def view(conn, %{"id" => id}) do

    {invoice, jobs, total, company} = InvoiceUtils.generate(id, false)
    render(conn, invoice: invoice, jobs: jobs, total: total,
                  company: company, layout: {Soroban.LayoutView, "invoice.html"})
  end

  @doc """
  Route: GET /invoices/<id>/edit
  Edit an invoice
  """
  def edit(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)
    changeset = Invoice.changeset(invoice)
    today = Date.utc_today()

    render(conn, "edit.html", invoice: invoice, changeset: changeset, today: today)
  end

  @doc """
  Route: PATCH/PUT /invoices/<id>
  Updates an invoice after editing
  """
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

  @doc """
  ROUTE: DELETE /invoices/<id>
  Deletes an invoice
  """
  def delete(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id)

    Repo.delete!(invoice)

    conn
    |> put_flash(:info, "Invoice deleted successfully.")
    |> redirect(to: invoice_path(conn, :index))
  end

  @doc """
  ROUTE: GET /clear_cache/<zip|pdf|all>
  Deletes Zip and PDF files from the file system
  """
  def clear_cache(conn, %{"type" => type}) do

    res = case type do
            "zip" -> Enum.join([Soroban.Pdf.pdf_path, "*.zip"])
            "pdf" -> Enum.join([Soroban.Pdf.pdf_path, "*.pdf"])
            "all" -> Enum.join([Soroban.Pdf.pdf_path, "*"])
            _     -> "error"
          end

    files = Path.wildcard(res)

    for f <- files do
      File.rm(f)
    end

    conn
    |> put_flash(:info, "Cache deleted successfully.")
    |> redirect(to: admin_path(conn, :index))
  end

  #
  # Private functions
  #

  @doc """
  Totals dollar amount from jobs within a date range for a client
  """
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
