defmodule Soroban.SettingController do
  @moduledoc """
  Setting controller
  This is where you set up your company information.  There should only be
  one company.
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.Setting

  plug :user_check

  @doc """
  Index page
  Route: GET /settings
  """
  def index(conn, _params) do
    settings = Repo.all(Setting)
    render(conn, "index.html", settings: settings)
  end

  @doc """
  Enter the company settings
  Route: GET /settings/new
  """
  def new(conn, _params) do
    changeset = Setting.changeset(%Setting{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Create the settings
  Route: POST /settings
  """
  def create(conn, %{"setting" => setting_params}) do
    new_params = if upload = setting_params["invoice_image"] do
      extension = Path.extname(upload.filename)
      File.cp(upload.path, "/priv/static/images/#{extension}")
      Map.put(setting_params, "invoice_image", upload.filename)
    else
      new_params = setting_params
    end

    changeset = Setting.changeset(%Setting{}, new_params)
    case Repo.insert(changeset) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting created successfully.")
        |> redirect(to: setting_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Show the settings
  Route: GET /settings/<id>
  """
  def show(conn, %{"id" => id}) do
    setting = Repo.get!(Setting, id)
    render(conn, "show.html", setting: setting)
  end

  @doc """
  Edit company settings
  Route: GET /settings/<id>
  """
  def edit(conn, %{"id" => id}) do
    setting = Repo.get!(Setting, id)
    changeset = Setting.changeset(setting)
    render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  @doc """
  Update settings after an edit
  Route: PATCH/PUT /settings/<id>
  """
  def update(conn, %{"id" => id, "setting" => setting_params}) do
    setting = Repo.get!(Setting, id)
    new_params = if upload = setting_params["invoice_image"] do
    extension = Path.extname(upload.filename)
    File.cp(upload.path, "priv/static/images/#{upload.filename}")
    Map.put(setting_params, "invoice_image", upload.filename)
  else
    new_params = setting_params
  end
    changeset = Setting.changeset(setting, new_params)

    case Repo.update(changeset) do
      {:ok, setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: setting_path(conn, :show, setting))
      {:error, changeset} ->
        render(conn, "show.html", setting: setting, changeset: changeset)
    end
  end

  @doc """
  Delete settings
  Route: DELETE /settings/<id>
  """
  def delete(conn, %{"id" => id}) do
    setting = Repo.get!(Setting, id)

    Repo.delete!(setting)

    conn
    |> put_flash(:info, "Setting deleted successfully.")
    |> redirect(to: setting_path(conn, :index))
  end
end
