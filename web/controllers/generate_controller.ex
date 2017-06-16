defmodule Soroban.GenerateController do
  use Soroban.Web, :controller
  
  import Soroban.Authorize

  alias Soroban.Client

  plug :user_check when action in [:index]
  plug :id_check when action in [:edit, :update, :delete]

  plug :load_clients when action in [:index] 

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp load_clients(conn, _) do
    clients = Repo.all from c in Client, select: {c.name, c.id}
    assign(conn, :clients, clients)
  end

end
