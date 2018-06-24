defmodule Soroban.Outstanding do
  @moduledoc """
  Utilities
  """

  import Ecto.Query
  alias Soroban.{Repo, Client, Invoice, Setting}

  @doc """
  Returns struct of all outstanding invoices
  """
  def outstanding() do
    settings = Repo.get(Setting, 1)
    pastdue = Timex.shift(Timex.now, days: -settings.days_pastdue)
    query = (from i in Invoice,
                where: i.paid == false,
                where: i.date < ^pastdue,
                order_by: i.date,
                select: i)
    Repo.all(query) |> Repo.preload(:client)
  end

  @doc """
  Returns total number of outstanding invoices
  """
  def total_count() do
    Enum.count(outstanding())
  end

  @doc """
  Returns number of outstanding invoices per client ID
  """
  def per_client_count(client_id) do
    settings = Repo.get(Setting, 1)
    invoices = Repo.get(Client, client_id) |> Repo.preload(:invoices)
    Enum.count(
      for od <- invoices.invoices, 
      Map.get(od, :paid) == false && days_past_due(od.date) > settings.days_pastdue, 
      do: od
    )
  end

  @doc """
  Returns number of days an invoice is past due.
  """
  def days_past_due(date) do
    settings = Repo.get(Setting, 1)
    pastdue = Timex.shift(Timex.now, days: -settings.days_pastdue)
    if date < pastdue do
      Date.diff(Timex.now, date)
    end
  end

  @doc """
  Returns boolean invoice is past due.
  """
  def is_past_due(date) do
    settings = Repo.get(Setting, 1)
    Date.diff(Timex.now, date) > settings.days_pastdue
  end

end
