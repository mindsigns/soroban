defmodule Soroban.LayoutView do
  use Soroban.Web, :view

  def current_year do
    date = Date.utc_today()
    date.year
  end
end
