defmodule Soroban.JobtypeController do
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.Jobtype

  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _params) do
    jobtypes = Repo.all(Jobtype)
    render(conn, "index.html", jobtypes: jobtypes)
  end

  def new(conn, _params) do
    changeset = Jobtype.changeset(%Jobtype{})
    render(conn, "new.html", changeset: changeset)
  end

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

  def show(conn, %{"id" => id}) do
    jobtype = Repo.get!(Jobtype, id)
    render(conn, "show.html", jobtype: jobtype)
  end

  def edit(conn, %{"id" => id}) do
    jobtype = Repo.get!(Jobtype, id)
    changeset = Jobtype.changeset(jobtype)
    render(conn, "edit.html", jobtype: jobtype, changeset: changeset)
  end

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

  def delete(conn, %{"id" => id}) do
    jobtype = Repo.get!(Jobtype, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(jobtype)

    conn
    |> put_flash(:info, "Jobtype deleted successfully.")
    |> redirect(to: jobtype_path(conn, :index))
  end
end
