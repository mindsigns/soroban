defmodule Soroban.PageController do
  @moduledoc """
  Page controller
  """
  use Soroban.Web, :controller

  @doc """
  Index page
  """
  def index(conn, _params) do
    render conn, "index.html", layout: {Soroban.LayoutView, "welcome.html"}
  end
end
