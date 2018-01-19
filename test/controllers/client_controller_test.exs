defmodule Soroban.ClientControllerTest do
  use Soroban.ConnCase

  alias Soroban.Client

  @valid_attrs %{
    address: "some content",
    contact: "some content",
    email: "some content",
    name: "some content"
  }
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, client_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing clients"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get(conn, client_path(conn, :new))
    assert html_response(conn, 200) =~ "New client"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post(conn, client_path(conn, :create), client: @valid_attrs)
    assert redirected_to(conn) == client_path(conn, :index)
    assert Repo.get_by(Client, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, client_path(conn, :create), client: @invalid_attrs)
    assert html_response(conn, 200) =~ "New client"
  end

  test "shows chosen resource", %{conn: conn} do
    client = Repo.insert!(%Client{})
    conn = get(conn, client_path(conn, :show, client))
    assert html_response(conn, 200) =~ "Show client"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, client_path(conn, :show, -1))
    end)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    client = Repo.insert!(%Client{})
    conn = get(conn, client_path(conn, :edit, client))
    assert html_response(conn, 200) =~ "Edit client"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    client = Repo.insert!(%Client{})
    conn = put(conn, client_path(conn, :update, client), client: @valid_attrs)
    assert redirected_to(conn) == client_path(conn, :show, client)
    assert Repo.get_by(Client, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    client = Repo.insert!(%Client{})
    conn = put(conn, client_path(conn, :update, client), client: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit client"
  end

  test "deletes chosen resource", %{conn: conn} do
    client = Repo.insert!(%Client{})
    conn = delete(conn, client_path(conn, :delete, client))
    assert redirected_to(conn) == client_path(conn, :index)
    refute Repo.get(Client, client.id)
  end
end
