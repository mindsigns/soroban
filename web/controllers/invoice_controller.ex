defmodule Soroban.InvoiceController do
  @moduledoc """
  Invoice Controller Route: /invoices
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.{Invoice, Job, Client, Email, Mailer, Pdf}
  alias Soroban.InvoiceUtils

  plug :user_check

  plug :load_clients when action in [:new, :edit, :create, :generate]
  plug :load_today when action in [:new, :show, :edit, :create, :send_email]

  plug :scrub_params, "id" when action in [:send_pdf, :show, :edit, :update, :delete, :view]
  plug :scrub_params, "invoice_id" when action in [:send_email, :show_invoice]
  plug :scrub_params, "invoice" when action in [:create, :update]
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

    msg = 
      if invoice.client.cc_email do
        Enum.join(["Invoice mailed to : ", invoice.client.contact, " <", invoice.client.email, "> and CC'd ", invoice.client.cc_email])
      else
        Enum.join(["Invoice mailed to : ", invoice.client.contact, " <", invoice.client.email, ">"])
      end

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

    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Route: POST /invoices/
  Inserts data into the database
  """
  def create(conn, %{"invoice" => invoice_params}) do
    changeset = Invoice.changeset(%Invoice{}, invoice_params)

    case changeset.valid? do
      false -> conn
                |> put_flash(:error, "Missing info")
                |> render("new.html", changeset: changeset)
      true ->
                client_id = Ecto.Changeset.get_field(changeset, :client_id)
                start_date = Ecto.Changeset.get_field(changeset, :start)
                end_date = Ecto.Changeset.get_field(changeset, :end)

      invtotal = total(client_id, start_date, end_date)
      advtotal = total_adv(client_id, start_date, end_date)

      if to_string(invtotal) == "$0.00" do
        conn
          |> put_flash(:error, "There are no jobs in that range.")
          |> render("new.html", changeset: changeset)

      else
        newchangeset = Ecto.Changeset.put_change(changeset, :total, invtotal)
        newchangeset2 = Ecto.Changeset.put_change(newchangeset, :fees_advanced, advtotal)

    case Repo.insert(newchangeset2) do
      {:ok, _invoice} ->
        conn
        |> put_flash(:info, "Invoice created successfully.")
        |> redirect(to: invoice_path(conn, :index))
      {:error, newchangeset2} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
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
             where: i.number == ^id,
             order_by: i.paid_on)
    invoices = Repo.all(query) |> Repo.preload([client: (from c in Client, order_by: c.name)])
    case Enum.count(invoices) do
      0 -> conn
            |> put_status(:not_found)
            |> render(Soroban.ErrorView, "error_msg.html")
      _ -> 
            total = InvoiceUtils.total(invoices)
            total_adv = InvoiceUtils.total_advanced(invoices)

     total_net = 
        if total > total_adv do
          Money.subtract(total, total_adv)
        else
          Money.subtract(total_adv, total)
        end 

      invoice_count = Enum.count(invoices)

      render(conn, "invoicelist.html", invoices: invoices, invoice_id: id, invoice_count: invoice_count, total: total, total_adv: total_adv, total_net: total_net)
    end
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
  Route: POST /invoices/paid/
  Mark an Invoice 'Paid'
  """
  def paid(conn, %{"paid" => %{"date" => paid_on, "invoice_id" => invoice_id}}) do 
    {:ok, date_paid} = Ecto.Date.cast({paid_on["year"], paid_on["month"], paid_on["day"]})

    invoice = Repo.get!(Invoice, invoice_id) |> Repo.preload(:client)
    changeset = Invoice.changeset(invoice)

    paidchangeset = Ecto.Changeset.put_change(changeset, :paid, true)
    newchangeset = Ecto.Changeset.put_change(paidchangeset, :paid_on, date_paid)

    case Repo.update(newchangeset) do
      {:ok, invoice} ->
        conn
        |> put_flash(:info, "Invoice updated successfully.")
        |> redirect(to: invoice_path(conn, :show, invoice_id))
      {:error, paidchangeset} ->
        conn
        |> put_flash(:error, "Error.")
        |> redirect(to: invoice_path(conn, :show, invoice_id))
    end
  end

  @doc """
  Route: POST /invoices/multipay/
  Mark an Invoice 'Paid'
  """
  def multipay(conn, %{"paid" => ids, "invoice_id" => %{"invoice_name" => invoice_id}}) do 
    idlist = for {id, "true"} <- ids, do: id
    paid_on = DateTime.utc_now()
    {:ok, date_paid} = Ecto.Date.cast({paid_on.year, paid_on.month, paid_on.day})

    for invoiceid <- idlist do
      invoice = Repo.get!(Invoice, invoiceid) |> Repo.preload(:client)
      changeset = Invoice.changeset(invoice)

      paidchangeset = Ecto.Changeset.put_change(changeset, :paid, true)
      newchangeset = Ecto.Changeset.put_change(paidchangeset, :paid_on, date_paid)
      Repo.update(newchangeset)
    end

        conn
        |> put_flash(:info, "Invoices marked 'Paid'.")
        |> redirect(to: invoice_invoice_path(conn, :show_invoice, invoice_id))
  end

  @doc """
  Route: GET /invoices/<id>/edit
  Edit an invoice
  """
  def edit(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)
    changeset = Invoice.changeset(invoice)

    render(conn, "edit.html", invoice: invoice, changeset: changeset)
  end

  @doc """
  Route: PATCH/PUT /invoices/<id>
  Updates an invoice after editing
  """
  def update(conn, %{"id" => id, "invoice" => invoice_params}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)
    changeset = Invoice.changeset(invoice, invoice_params)

    # Remove any PDF's that might be cached. Remove Zips
    InvoiceUtils.cleanup(invoice.client.name, invoice.number)

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
  ROUTE: GET /invoices/outstanding
  display outstanding invoices

  def index(conn, _params) do

  query = (from i in Invoice,
              where: i.paid == false,
              order_by: i.date,
              select: i)

    invoices = Repo.all(query)
    render(conn, "index.html", invoices: invoices)
  end
"""
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

  #Totals dollar amount from jobs within a date range for a client
  def total(client, startdate, enddate) do
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

def total_adv(client, startdate, enddate) do
    query = (from j in Job,
              where: j.date >= ^startdate,
              where: j.date <= ^enddate,
              where: j.client_id == ^client,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    jtotal = for n <- jobs, do: Map.get(n, :fees_advanced)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))
    total
end

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, order_by: c.name, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

  defp load_today(conn, _) do
    today = Date.utc_today()
    assign(conn, :today, today)
  end

end
