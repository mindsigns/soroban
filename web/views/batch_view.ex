defmodule Soroban.BatchView do
  use Soroban.Web, :view
  use Rummage.Phoenix.View

  def today do
    today = Date.utc_today()
  end
end
