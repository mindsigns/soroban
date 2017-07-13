defmodule InvoiceUtils do
  import Ecto.Query

  alias Soroban.{Job, Invoice, Setting, Repo}

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

  {invoice, jobs, total, company}
  end

  def total(jobs) do
    jtotal = for n <- jobs, do: Map.get(n, :total)
    ftotal = for n <- jtotal, do: Map.get(n, :amount)
    total = Money.new(Enum.sum(ftotal))                  
    total
  end

end
