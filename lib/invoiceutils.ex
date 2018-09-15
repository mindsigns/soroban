defmodule Soroban.InvoiceUtils do
  @moduledoc """
  Invoice helper functions
  """

  import Ecto.Query
  use Drab.Commander

  alias Soroban.{Job, Invoice, Setting, Repo}
  alias Soroban.Pdf

  @doc """
  Generates invoice/PDF
  Returns invoice/jobs/total/company for rendering templates
  """
  def generate(invoice_id, pdf_tf) do
    invoice = Repo.get!(Invoice, invoice_id) |> Repo.preload(:client)

    jobs = get_jobs(invoice)

    company = Repo.one(from(s in Setting, limit: 1))

    if length(jobs) > 0 do
      total = total(jobs)
      adv_tot = total_advanced(jobs)

      changeset = Ecto.Changeset.change(invoice, %{total: total})
      Repo.update!(changeset)
      changeset2 = Ecto.Changeset.change(invoice, %{fees_advanced: adv_tot})
      Repo.update!(changeset2)

      case pdf_tf do
        true -> Pdf.to_pdf(invoice, jobs, total, company)
        false -> "skipping pdf generation"
      end

      {invoice, jobs, total, company}
    else
      {invoice, jobs, 0, company}
    end
  end

  @doc """
  Generates invoice/PDF
  No return for template rendering. Used for batch processing
  """
  def generate_batch(invoice_id, pdf_tf) do
    invoice = Repo.get!(Invoice, invoice_id) |> Repo.preload(:client)

    jobs = get_jobs(invoice)

    company = Repo.one(from(s in Setting, limit: 1))

    total = total(jobs)
    adv_tot = total_advanced(jobs)

    changeset = Ecto.Changeset.change(invoice, %{total: total})
    Repo.update!(changeset)
    changeset2 = Ecto.Changeset.change(invoice, %{fees_advanced: adv_tot})
    Repo.update!(changeset2)

    case pdf_tf do
      true -> Pdf.to_pdf(invoice, jobs, total, company)
      false -> "skipping pdf generation"
    end
  end

  @doc """
  Return total dollar amount of jobs
  """
  def total(jobs) do
    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    Money.new(Enum.sum(ftotal))
  end

  def total_advanced(jobs) do
    jtotal = for n <- jobs, do: Map.get(n, :fees_advanced)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    Money.new(Enum.sum(ftotal))
  end

  def batch_job(socket, clients, params) do
    %{
      "invoice" => %{"date" => date, "end" => end_date, "start" => start_date, "number" => number}
    } = params

    for c <- clients do
      client = Repo.get(Soroban.Client, c)
      case jobcount(c, params) do
        0 ->
            poke(socket, text: "No jobs for the client #{client.name}")
        _ ->
            invoice_id = new_invoice(c, date, end_date, start_date, number)
            generate(invoice_id, true)
            poke(socket, text: "Invoicing for : #{client.name}")
      end
    end

    poke(socket, text: "Done generating invoices! <a href='/invoices'>View</a>")
  end

  def batch_email(invoice_id_list) do
    for i <- invoice_id_list do
      {invoice, jobs, total, company} = generate(i, false)

      case is_nil(invoice.client.email) do
        false ->
          Soroban.Email.invoice_html_email(invoice.client.email, invoice, jobs, total, company)
          |> Soroban.Mailer.deliver_later()

        true ->
          Slingbag.add(invoice.client.name)
      end
    end
  end

  def new_invoice(id, date, end_date, start_date, number) do
    changeset =
      Invoice.changeset(%Invoice{}, %{
        "client_id" => id,
        "number" => number,
        "date" => date,
        "end" => end_date,
        "start" => start_date
      })

    result = Repo.insert_or_update!(changeset)
    result.id
  end

  @doc """
  Remove any cached PDFs after modifying an invoice
  """
  def cleanup(client, invoice_number) do
    filename = Soroban.Pdf.create_file_name(client, invoice_number)

    file = Enum.join([Soroban.Pdf.pdf_path(), filename])

    case File.exists?(file) do
      true -> File.rm(file)
      false -> IO.puts("No File")
    end
  end

  def jobcount(client_id, params) do
    %{"invoice" => %{"date" => _, "end" => end_date, "start" => start_date, "number" => _}} =
      params

    query =
      from(
        j in Job,
        where: j.date >= ^start_date,
        where: j.date <= ^end_date,
        where: j.client_id == ^client_id,
        order_by: j.date,
        select: j
      )

    jobs = Repo.all(query) |> Repo.preload(:client)
    length(jobs)
  end

  def get_jobs(invoice) do
    query =
      from(
        j in Job,
        where: j.date >= ^invoice.start,
        where: j.date <= ^invoice.end,
        where: j.client_id == ^invoice.client_id,
        order_by: j.date,
        select: j
      )

    Repo.all(query) |> Repo.preload(:client)
  end
end
