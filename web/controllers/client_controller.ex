defmodule Soroban.ClientController do
  @moduledoc """
  Client controller
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.Client

  plug :user_check

  plug :scrub_params, "id" when action in [:show, :edit, :update, :delete]
  plug :scrub_params, "client" when action in [:create]
  plug :scrub_params, "client_id" when action in [:client_delete]

  @doc """
  Index function
  Route: GET /clients
  """
  def index(conn, _params) do

    clients = Repo.all(Client)

    render(conn, "index.html", clients: clients)
  end

  @doc """
  Create a new client
  Route: GET /clients/new
  """
  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Create the new client
  ROUTE: POST /clients
  """
  def create(conn, %{"client" => client_params}) do
    changeset = Client.changeset(%Client{}, client_params)

    case Repo.insert(changeset) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, "Client created successfully.")
        |> redirect(to: client_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Show a single client
  ROUTE: GET /clients/<id>
  """
  def show(conn, %{"id" => id}) do
    client = Repo.get!(Client, id) |> Repo.preload(:invoices)
    render(conn, "show.html", client: client)
  end

  @doc """
  Edit a client
  ROUTE: GET /clients/<id>/edit
  """
  def edit(conn, %{"id" => id}) do
    client = Repo.get!(Client, id)
    changeset = Client.changeset(client)
    render(conn, "edit.html", client: client, changeset: changeset)
  end

  @doc """
  Update the client info
  Route: PATCH/PUT /clients/<id>
  """
  def update(conn, %{"id" => id, "client" => client_params}) do
    client = Repo.get!(Client, id)
    changeset = Client.changeset(client, client_params)

    case Repo.update(changeset) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Client updated successfully.")
        |> redirect(to: client_path(conn, :show, client))
      {:error, changeset} ->
        render(conn, "edit.html", client: client, changeset: changeset)
    end
  end

  @doc """
  Warning page for client removal
  Route: GET /clients/<client_id>/warning
  """
  def client_delete(conn, %{"client_id" => id}) do
    client = Repo.get!(Client, id) 
    render(conn, "warning.html", client: client)
  end

  @doc """
  Delete a client
  Route: DELETE /clients/<id>
  """
  def delete(conn, %{"id" => id}) do
    client = Repo.get!(Client, id)

    Repo.delete!(client)

    conn
    |> put_flash(:info, "Client deleted successfully.")
    |> redirect(to: client_path(conn, :index))
  end
end
