defmodule Soroban.OutstandingController do
  @moduledoc """
  Invoice Controller Route: /outstanding
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.{Invoice, Client}
  alias Soroban.InvoiceUtils

  plug :user_check

  #plug :load_clients when action in [:new, :edit, :create, :generate]
  #plug :load_today when action in [:new, :show, :edit, :create, :send_email]

  @doc """
  Route: GET /invoices
  Shows a list of Invoices by unique invoice IDs.
  """
  def index(conn, _params) do

    pastdue = Timex.shift(Timex.now, days: -60)
    query = (from i in Invoice,
            where: i.paid == false,
            where: i.date < ^pastdue,
            order_by: i.date,
            select: i)
    invoices = Repo.all(query) |> Repo.preload(:client)

    count = Enum.count invoices
    render(conn, "index.html", invoices: invoices, count: count)
  end
end
