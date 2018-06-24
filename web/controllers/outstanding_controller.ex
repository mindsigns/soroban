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

    invoices = Soroban.Outstanding.outstanding
    count = Soroban.Outstanding.total_count
    render(conn, "index.html", invoices: invoices, count: count)
  end

end
