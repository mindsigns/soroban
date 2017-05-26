defmodule Soroban.JobView do
  use Soroban.Web, :view

  def today do
    today = Date.utc_today()
  end

end
