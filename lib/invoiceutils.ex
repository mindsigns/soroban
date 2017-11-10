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

    company = Repo.one(from s in Setting, limit: 1)

    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    total = total(jobs)

    changeset = Ecto.Changeset.change(invoice, %{total: total})
    Repo.update!(changeset)

  case pdf_tf do
    true  -> Pdf.to_pdf(invoice, jobs, total, company)
    false -> "skipping pdf generation"
  end

  {invoice, jobs, total, company}
  end

  @doc """
  Generates invoice/PDF
  No return for template rendering. Used for batch processing
  """
  def generate_batch(invoice_id, pdf_tf) do
    invoice = Repo.get!(Invoice, invoice_id) |> Repo.preload(:client)

    company = Repo.one(from s in Setting, limit: 1)

    query = (from j in Job,
              where: j.date >= ^invoice.start,
              where: j.date <= ^invoice.end,
              where: j.client_id == ^invoice.client_id,
              order_by: j.date,
              select: j)

    jobs = Repo.all(query) |> Repo.preload(:client)

    total = total(jobs)

    changeset = Ecto.Changeset.change(invoice, %{total: total})
    Repo.update!(changeset)

  case pdf_tf do
    true  -> Pdf.to_pdf(invoice, jobs, total, company)
    false -> "skipping pdf generation"
  end
  end

  @doc """
	Return total dollar amount of jobs
  """
  def total(jobs) do
    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))
    total
  end

  def batch_job(socket, clients, params) do
    IO.inspect params
    %{"invoice" => %{"date" => date, "end" => end_date,"start" => start_date, "number" => number}} =  params

    for c <- clients do
    case Enum.count(Repo.all from c in Soroban.Client,
                      join: j in Soroban.Job,
                      where: j.client_id == ^c) do
        0 ->  "No Jobs"
        _ ->  invoice_id = new_invoice(c, date, end_date, start_date, number)
              generate(invoice_id, true)
              client = Repo.get(Soroban.Client, c)
              poke socket, text: Enum.join(["Invoicing for : ", client.name])
      end
    end
    poke socket, text: "Done generating invoices! <a href='/invoices'>View</a>"
  end

  def batch_email(invoice_id_list) do
    for i <- invoice_id_list do
      {invoice, jobs, total, company} = generate(i, false)

      case is_nil(invoice.client.email) do
        false -> Soroban.Email.invoice_html_email(invoice.client.email,
                                                  invoice, jobs, total,
                                                  company)
                  |> Soroban.Mailer.deliver_later
        true  -> Slingbag.add(invoice.client.name)
      end
    end
  end

  def new_invoice(id, date, end_date, start_date, number) do
    changeset = Invoice.changeset(%Invoice{}, %{"client_id" => id,
                                    "number" => number,
                                    "date" => date,
                                    "end" => end_date,
                                    "start" => start_date})
    result =  Repo.insert_or_update!(changeset)
    result.id
 end

 @doc """
  Remove any cached PDFs after modifying an invoice
 """
 def cleanup(client, invoice_number) do
	filename = Soroban.Pdf.create_file_name(client, invoice_number)

    file = Enum.join([Soroban.Pdf.pdf_path(), filename])

    case File.exists?(file) do
       true  -> File.rm(file)
       false -> IO.puts "No File"
    end

 end

end
