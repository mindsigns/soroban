defmodule Soroban.JobController do
  @moduledoc """
  Job Controller
  """
  use Soroban.Web, :controller

  import Soroban.Authorize
  import Ecto.Query

  alias Soroban.{Job, Client}

  plug :user_check

  plug :load_services when action in [:index, :new, :create, :edit, :update]
  plug :load_jobtypes when action in [:index, :new, :create, :edit, :update]
  plug :load_clients when action in [:index, :new, :create, :edit, :update]

  @doc """
  Index page
  Route: GET /jobs
  """
  def index(conn, _params) do

    query = from j in Job, order_by: [desc: :date], limit: 300
    jobs = Repo.all(query) |> Repo.preload(:client)

    render(conn, "index.html", jobs: jobs)
  end

  @doc """
  Create a new job
  Route: GET /jobs/new
  """
  def new(conn, _params) do
    changeset = Job.changeset(%Job{})
    today = Date.utc_today()
    render(conn, "new.html", changeset: changeset, today: today)
  end

  @doc """
  Create a new job
  Route: POST /jobs
  """
  def create(conn, %{"job" => job_params}) do
    changeset = Job.changeset(%Job{}, job_params)
    case Repo.insert(changeset) do
      {:ok, _job} ->
        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: job_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Show a single job
  Route: GET /jobs/<id>
  """
  def show(conn, %{"id" => id}) do
    job = Repo.get!(Job, id) |> Repo.preload(:client)
    render(conn, "show.html", job: job)
  end

  @doc """
  Edit a job
  Route: GET /jobs/<id>/edit
  """
  def edit(conn, %{"id" => id}) do
    job = Repo.get!(Job, id) |> Repo.preload(:client)
    changeset = Job.changeset(job)
    today = Date.utc_today()
    render(conn, "edit.html", job: job, changeset: changeset, today: today)
  end

  @doc """
  Update the job after an edit
  Route: PATCH/PUT /jobs/<id>
  """
  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Repo.get!(Job, id)
    changeset = Job.changeset(job, job_params)

    case Repo.update(changeset) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: job_path(conn, :show, job))
      {:error, changeset} ->
        render(conn, "edit.html", job: job, changeset: changeset)
    end
  end

  @doc """
  Deletes a job
  Route: DELETE /jobs/<id>
  """
  def delete(conn, %{"id" => id}) do
    job = Repo.get!(Job, id)
    Repo.delete!(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: job_path(conn, :index))
  end

  #
  # Private Functions
  #

   defp load_services(conn, _) do
      services = Repo.all from c in Soroban.Service, select: c.type
      assign(conn, :services, services)
   end

   defp load_jobtypes(conn, _) do
      jobtypes = Repo.all from c in Soroban.Jobtype, select: c.type
      assign(conn, :jobtypes, jobtypes)
   end

   defp load_clients(conn, _) do
      clients = Repo.all from c in Client, order_by: c.name, select: {c.name, c.id}
      assign(conn, :clients, clients)
   end

end
