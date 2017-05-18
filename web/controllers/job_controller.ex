defmodule Soroban.JobController do
  use Soroban.Web, :controller

  alias Soroban.Job
  alias Soroban.Service
  alias Soroban.Jobtype

  plug :load_services when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    jobs = Repo.all(Job)
    render(conn, "index.html", jobs: jobs)
  end

  def new(conn, _params) do
    changeset = Job.changeset(%Job{})
    services = Repo.all from c in Soroban.Service, select: c.type
    jobtypes = Repo.all from c in Soroban.Jobtype, select: c.type
    render(conn, "new.html", changeset: changeset, services: services, jobtypes: jobtypes)
  end

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

  def show(conn, %{"id" => id}) do
    job = Repo.get!(Job, id)
    render(conn, "show.html", job: job)
  end

  def edit(conn, %{"id" => id}) do
    job = Repo.get!(Job, id)
    changeset = Job.changeset(job)
    services = Repo.all from c in Soroban.Service, select: c.type
    render(conn, "edit.html", job: job, changeset: changeset, services: services)
  end

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

  def delete(conn, %{"id" => id}) do
    job = Repo.get!(Job, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: job_path(conn, :index))
  end

  defp load_services(conn, _) do
    services = Repo.all from c in Soroban.Service, select: c.type
    assign(conn, :services, services)
  end

  defp load_jobtypes(conn, _) do
    jobtypes = Repo.all from c in Soroban.Jobtype, select: c.type
    assign(conn, :jobtypes, jobtypes)
  end


end
