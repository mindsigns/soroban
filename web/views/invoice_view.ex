defmodule Soroban.InvoiceView do
  use Soroban.Web, :view
  use Rummage.Phoenix.View

  def today do
    today = Date.utc_today()
  end
end
