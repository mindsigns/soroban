defmodule Soroban.PageController do
  use Soroban.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", layout: {Soroban.LayoutView, "welcome.html"}
  end
end
