defmodule Soroban.JobtypeController do
  @moduledoc """
  JobType controller
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.Jobtype

  plug :user_check

  @doc """
  Index page
  Route: GET /jobtypes
  """
  def index(conn, _params) do
    jobtypes = Repo.all(Jobtype)
    render(conn, "index.html", jobtypes: jobtypes)
  end

  @doc """
  Create a new job type
  Route: GET /jobtypes/new
  """
  def new(conn, _params) do
    changeset = Jobtype.changeset(%Jobtype{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Create the new job type
  Route: POST /jobtypes
  """
  def create(conn, %{"jobtype" => jobtype_params}) do
    changeset = Jobtype.changeset(%Jobtype{}, jobtype_params)

    case Repo.insert(changeset) do
      {:ok, _jobtype} ->
        conn
        |> put_flash(:info, "Jobtype created successfully.")
        |> redirect(to: jobtype_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Show a job type
  Route: GET /jobtypes/<id>
  """
  def show(conn, %{"id" => id}) do
    jobtype = Repo.get!(Jobtype, id)
    render(conn, "show.html", jobtype: jobtype)
  end

  @doc """
  Edit a job type
  Route: GET /jobtypes/<id>/edit
  """
  def edit(conn, %{"id" => id}) do
    jobtype = Repo.get!(Jobtype, id)
    changeset = Jobtype.changeset(jobtype)
    render(conn, "edit.html", jobtype: jobtype, changeset: changeset)
  end

  @doc """
  Update a job type after editing
  Route: PATCH/PUT /jobtypes/<id>
  """
  def update(conn, %{"id" => id, "jobtype" => jobtype_params}) do
    jobtype = Repo.get!(Jobtype, id)
    changeset = Jobtype.changeset(jobtype, jobtype_params)

    case Repo.update(changeset) do
      {:ok, jobtype} ->
        conn
        |> put_flash(:info, "Jobtype updated successfully.")
        |> redirect(to: jobtype_path(conn, :show, jobtype))
      {:error, changeset} ->
        render(conn, "edit.html", jobtype: jobtype, changeset: changeset)
    end
  end

  @doc """
  Delete a job type
  Route: DELETE /jobtypes/<id>
  """
  def delete(conn, %{"id" => id}) do
    jobtype = Repo.get!(Jobtype, id)
    Repo.delete!(jobtype)

    conn
    |> put_flash(:info, "Jobtype deleted successfully.")
    |> redirect(to: jobtype_path(conn, :index))
  end
end
