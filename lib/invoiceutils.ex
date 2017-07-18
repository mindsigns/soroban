defmodule Soroban.InvoiceUtils do
  @moduledoc """
  Invoice helper functions
  """

  import Ecto.Query

  alias Soroban.{Job, Invoice, Setting, Repo}
  alias Soroban.Pdf

  def generate(invoice_id) do
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

    Pdf.to_pdf(invoice, jobs, total, company)

  {invoice, jobs, total, company}
  end

  def total(jobs) do
    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  
    total
  end

  def batch_job(_conn, clients, params) do
    %{"invoice" => %{"date" => date, "end" => end_date, "start" => start_date, "number" => number}} =  params

    for c <- clients do
      case Enum.count(Repo.all from c in Soroban.Client, join: j in Soroban.Job, where: j.client_id == ^c) do
        0 ->  "No Jobs"
        _ ->  invoice_id = new_invoice(c, date, end_date, start_date, number)
              generate(invoice_id)
      end
    end
  end

  defp new_invoice(id, date, end_date, start_date, number) do
    changeset = Invoice.changeset(%Invoice{}, %{"client_id" => id,
                                    "number" => number,
                                    "date" => date,
                                    "end" => end_date,
                                    "start" => start_date})
    result =  Repo.insert_or_update!(changeset)
    result.id
 end

end
