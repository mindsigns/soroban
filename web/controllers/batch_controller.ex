defmodule Soroban.BatchController do
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.Invoice
  alias Soroban.Job
  alias Soroban.Client
  alias Soroban.Setting


  plug :user_check 

  plug :load_clients when action in [:index, :new, :create, :edit, :show, :update, :generate] 

  def index(conn, params) do

    {query, rummage} = Invoice
      |> Invoice.rummage(params["rummage"])

    invoices = query
               |> distinct(:number)
               |> Repo.all

    render(conn, "index.html", invoices: invoices, rummage: rummage)
  end

  def generate(conn, %{"invoice_id" => id}) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)

    company = Repo.one(from s in Setting, limit: 1)

    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  

    job_count = Enum.count(jobs)

    changeset = Ecto.Changeset.change(invoice, %{total: total})
    Repo.update!(changeset)

    Soroban.Email.invoice_html_email("jon@deathray.tv", invoice, jobs, total, company)
      |> Soroban.Mailer.deliver_later

    render(conn, "generate.html", invoice: invoice, jobs: jobs, total: total, job_count: job_count)
  end

  def batch(conn, _params) do
    render(conn, "batch.html")
  end

  def generate_all(conn, params) do
    %{"invoice" => %{"date" => date, "end" => end_date, "start" => start_date, "number" => number}} =  params

    clients = Repo.all from c in Client, select: c.id

    for c <- clients do
      case Enum.count(Repo.all from c in Soroban.Client, join: j in Soroban.Job, where: j.client_id == ^c) do
        0 ->  "No Jobs"
        _ ->  invoice_id = new_invoice(c, date, end_date, start_date, number)
              generate(conn, %{"invoice_id" => invoice_id})
      end
    end

    render(conn, "batch.html")
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

    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  

    job_count = Enum.count(jobs)

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
    query = (from i in Invoice,
              where: i.number == ^id)

    Repo.delete_all(query)

    conn
    |> put_flash(:info, "Invoice deleted successfully.")
    |> redirect(to: invoice_path(conn, :index))
  end

  def total_all() do
    ids = Repo.all from i in Invoice, select: i.id
    for n <- ids, do: total(n)
  end

  def total(id) do
    invoice = Repo.get!(Invoice, id) |> Repo.preload(:client)
    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  
    changeset = Ecto.Changeset.change(invoice, %{total: total})
    Repo.update!(changeset)
end

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

  defp new_invoice(id, date, end_date, start_date, number ) do
    changeset = Invoice.changeset(%Invoice{}, %{"client_id" => id,
                                                "number" => number,
                                                "date" => date,
                                                "end" => end_date,
                                                "start" => start_date})
   result =  Repo.insert_or_update!(changeset)
   result.id
  end

end
