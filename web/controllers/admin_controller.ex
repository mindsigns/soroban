defmodule Soroban.AdminController do
  use Soroban.Web, :controller
  
  import Soroban.Authorize

    plug :user_check when action in [:index]
    plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _params) do
    render conn, "index.html"
  end
end