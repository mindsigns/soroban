defmodule Soroban.SettingController do
  use Soroban.Web, :controller

  alias Soroban.Setting

  def index(conn, _params) do
    settings = Repo.all(Setting)
    render(conn, "index.html", settings: settings)
  end

  def new(conn, _params) do
    changeset = Setting.changeset(%Setting{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"setting" => setting_params}) do
    changeset = Setting.changeset(%Setting{}, setting_params)

    case Repo.insert(changeset) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting created successfully.")
        |> redirect(to: setting_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    setting = Repo.get!(Setting, id)
    render(conn, "show.html", setting: setting)
  end

  def edit(conn, %{"id" => id}) do
    setting = Repo.get!(Setting, id)
    changeset = Setting.changeset(setting)
    render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  def update(conn, %{"id" => id, "setting" => setting_params}) do
    setting = Repo.get!(Setting, id)
    changeset = Setting.changeset(setting, setting_params)

    case Repo.update(changeset) do
      {:ok, setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: setting_path(conn, :show, setting))
      {:error, changeset} ->
        render(conn, "edit.html", setting: setting, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    setting = Repo.get!(Setting, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(setting)

    conn
    |> put_flash(:info, "Setting deleted successfully.")
    |> redirect(to: setting_path(conn, :index))
  end
end
