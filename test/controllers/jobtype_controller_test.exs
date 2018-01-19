defmodule Soroban.JobtypeControllerTest do
  use Soroban.ConnCase

  alias Soroban.Jobtype
  @valid_attrs %{type: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, jobtype_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing jobtypes"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get(conn, jobtype_path(conn, :new))
    assert html_response(conn, 200) =~ "New jobtype"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post(conn, jobtype_path(conn, :create), jobtype: @valid_attrs)
    assert redirected_to(conn) == jobtype_path(conn, :index)
    assert Repo.get_by(Jobtype, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, jobtype_path(conn, :create), jobtype: @invalid_attrs)
    assert html_response(conn, 200) =~ "New jobtype"
  end

  test "shows chosen resource", %{conn: conn} do
    jobtype = Repo.insert!(%Jobtype{})
    conn = get(conn, jobtype_path(conn, :show, jobtype))
    assert html_response(conn, 200) =~ "Show jobtype"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, jobtype_path(conn, :show, -1))
    end)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    jobtype = Repo.insert!(%Jobtype{})
    conn = get(conn, jobtype_path(conn, :edit, jobtype))
    assert html_response(conn, 200) =~ "Edit jobtype"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    jobtype = Repo.insert!(%Jobtype{})
    conn = put(conn, jobtype_path(conn, :update, jobtype), jobtype: @valid_attrs)
    assert redirected_to(conn) == jobtype_path(conn, :show, jobtype)
    assert Repo.get_by(Jobtype, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    jobtype = Repo.insert!(%Jobtype{})
    conn = put(conn, jobtype_path(conn, :update, jobtype), jobtype: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit jobtype"
  end

  test "deletes chosen resource", %{conn: conn} do
    jobtype = Repo.insert!(%Jobtype{})
    conn = delete(conn, jobtype_path(conn, :delete, jobtype))
    assert redirected_to(conn) == jobtype_path(conn, :index)
    refute Repo.get(Jobtype, jobtype.id)
  end
end
