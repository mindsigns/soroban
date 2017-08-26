defmodule Soroban.UserController do
  @moduledoc """
  User controller
  """
  use Soroban.Web, :controller

  import Soroban.Authorize

  alias Soroban.{Email, User}
  alias Openmaize.ConfirmEmail

  plug :user_check

  @doc """
  User index page
  Route: GET /users
  """
  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  @doc """
  New user
  Route: GET /users/new
  """
  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Create the new user
  Route: POST /users
  """
  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    {key, link} = ConfirmEmail.gen_token_link(email)
    changeset = User.auth_changeset(%User{}, user_params, key)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        Email.ask_confirm(email, link)
        auth_info conn, "User created successfully", user_path(conn, :index)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Show a user
  Route: GET /users/<id>
  """
  def show(conn, %{"id" => id}) do
    user = Repo.get(Soroban.User, id)
    render conn, "show.html", user: user
  end

  @doc """
  Edit a user
  Route: GET /users/<id>/edit
  """
  def edit(conn, %{"id" => id}) do
    user = Repo.get(Soroban.User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  @doc """
  Update a user after an edit
  Route: PATCH/PUT /users/<id>
  """
  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        auth_info conn, "User updated successfully", user_path(conn, :show, user)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  @doc """
  Delete a user
  Route: DELETE /users/<id>
  """
  def delete(conn,  %{"id" => id}) do
	   user = Repo.get!(User, id)
     Repo.delete!(user)
	    if %{current_user: user} == user do
    	   configure_session(conn, drop: true)
	    else
        conn
          |> auth_info("User deleted successfully", user_path(conn, :index))
  	  end
  end
end
