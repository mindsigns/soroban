defmodule Soroban.ServiceController do
  @moduledoc """
  Service type controller
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.Service

  plug :user_check

  @doc """
  Index page
  Route: GET /service
  """
  def index(conn, _params) do
    services = Repo.all(Service)
    render(conn, "index.html", services: services)
  end

  @doc """
  Create a new service type
  Route GET /service/new
  """
  def new(conn, _params) do
    changeset = Service.changeset(%Service{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Create the service type
  Route: POST /service
  """
  def create(conn, %{"service" => service_params}) do
    changeset = Service.changeset(%Service{}, service_params)

    case Repo.insert(changeset) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service created successfully.")
        |> redirect(to: service_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Show a service type
  Route: GET /service/<id>
  """
  def show(conn, %{"id" => id}) do
    service = Repo.get!(Service, id)
    render(conn, "show.html", service: service)
  end

  @doc """
  Edit a service type
  Route: GET /service/<id>/edit
  """
  def edit(conn, %{"id" => id}) do
    service = Repo.get!(Service, id)
    changeset = Service.changeset(service)
    render(conn, "edit.html", service: service, changeset: changeset)
  end

  @doc """
  Update the service type after editing
  Route: PATCH/PUT /service/<id>
  """
  def update(conn, %{"id" => id, "service" => service_params}) do
    service = Repo.get!(Service, id)
    changeset = Service.changeset(service, service_params)

    case Repo.update(changeset) do
      {:ok, service} ->
        conn
        |> put_flash(:info, "Service updated successfully.")
        |> redirect(to: service_path(conn, :show, service))
      {:error, changeset} ->
        render(conn, "edit.html", service: service, changeset: changeset)
    end
  end

  @doc """
  Delete a service type
  Route: DELETE /service/<id>
  """
  def delete(conn, %{"id" => id}) do
    service = Repo.get!(Service, id)

    Repo.delete!(service)

    conn
    |> put_flash(:info, "Service deleted successfully.")
    |> redirect(to: service_path(conn, :index))
  end
end
