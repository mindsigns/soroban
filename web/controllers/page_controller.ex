defmodule Soroban.PageController do
  use Soroban.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
