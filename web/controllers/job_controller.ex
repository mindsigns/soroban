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

    render(conn, "index.html", jobs: jobs, year: nil, month: nil)
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

  @doc """
  Render an Archive page of jobs by Month/Year
  Route: GET /joblist
  """
  def archive(conn, _params) do
    yearlist = get_year()
    years = for y <- yearlist, do: round(y)

    stuff = for year <- years do
          get_month(year)
    end

    render(conn, "archive.html", stuff: stuff)
  end

  @doc """
  Display jobs by Year
  Route: GET /listjobs/<year>
  """
  def list_by_year(conn, %{"year" => string}) do
    year = String.to_integer(string)
    jobs = Job
            |> where([e], fragment("date_part('year', ?)", e.date) == ^year)
            |> Repo.all
            |> Repo.preload(:client)

    render(conn, "index.html", jobs: jobs)
  end

  @doc """
  Display jobs by month for a given year
  Route: GET /listjobs/<year>/<month>
  """
def list_by_month(conn, %{"month" => month_str, "year" => year_str}) do
    year = String.to_integer(year_str)
    month = assign_month_num(month_str)
    jobs = Job
            |> where([e], fragment("date_part('year', ?)", e.date) == ^year)
            |> where([e], fragment("date_part('month', ?)", e.date) == ^month)
            |> order_by(desc: :date)
            |> Repo.all
            |> Repo.preload(:client)

    render(conn, "index.html", jobs: jobs, year: year_str, month: month_str)
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

  defp get_year() do
    res = Job
            |> group_by([e], fragment("date_part('year', ?)", e.date))
            |> select([e], fragment("date_part('year', ?)", e.date))
            |> distinct(true)
            |> Repo.all

    Enum.sort(res)
  end

  defp get_month(year) do
    res = Job
            |> group_by([e], fragment("date_part('month', ?)", e.date))
            |> select([e], fragment("date_part('month', ?)", e.date))
            |> where([e], fragment("date_part('year', ?)", e.date) == ^year)
            |> distinct(true)
            |> Repo.all


    months = for y <- res, do:
              assign_month(y)

              %{year: year, months: months}
  end

   defp assign_month(x) do
      case round(x) do
        1  -> "Jan"
        2  -> "Feb"
        3  -> "Mar"
        4  -> "Apr"
        5  -> "May"
        6  -> "Jun"
        7  -> "Jul"
        8  -> "Aug"
        9  -> "Sep"
        10 -> "Oct"
        11 -> "Nov"
        12 -> "Dec"
        _  -> "uhhh"
      end
   end

   defp assign_month_num(x) do
      case x do
        "Jan" -> 01
        "Feb" -> 02
        "Mar" -> 03
        "Apr" -> 04
        "May" -> 05
        "Jun" -> 06
        "Jul" -> 07
        "Aug" -> 08
        "Sep" -> 09
        "Oct" -> 10
        "Nov" -> 11
        "Dec" -> 12
        _  -> "uhhh"
      end
   end

end
