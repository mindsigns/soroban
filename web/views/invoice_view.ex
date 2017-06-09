defmodule Soroban.InvoiceView do
  use Soroban.Web, :view

  def today do
    today = Date.utc_today()
  end
end
