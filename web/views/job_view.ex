defmodule Soroban.JobView do
  use Soroban.Web, :view

  def today do
    #today = Date.to_erl(Date.utc_today())
    today = Date.utc_today()
  end

end
