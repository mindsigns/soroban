defmodule Soroban.Trans do
  @moduledoc """
  Utilities
  """

  import Ecto.Query
  alias Soroban.{Repo, Job, Invoice}

  @doc """
  Update advanced fees from nil to $0.00
  """
  def update_job_adv_fees() do
    query = (from j in Soroban.Job, where: is_nil(j.fees_advanced) == true)
    jobs = Repo.all(query)

    ids = for n <- jobs, do: Map.get(n, :id)
    ids

    Enum.each(jobs, fn(job) ->
      changeset = Job.changeset(job, %{fees_advanced: Money.new(0)})
      Repo.update(changeset)
    end)
  end

  @doc """
  Update Invoice Advanced fees field
  """
  def update_inv_adv_fees() do
    # query = (from j in Invoice, where: is_nil(j.fees_advanced) == true)
    
    invs = Repo.all(Invoice)

    Enum.each(invs, fn(invoice) ->
      jobs = Soroban.InvoiceUtils.get_jobs(invoice)
      adv_tot = Soroban.InvoiceUtils.total_advanced(jobs)
      IO.inspect adv_tot

      #changeset = Invoice.changeset(invoice, %{fees_advanced: Money.new(adv_tot)})
      changeset = Invoice.changeset(invoice, %{fees_advanced: adv_tot})
      Repo.update(changeset)
    end)
  end

end
