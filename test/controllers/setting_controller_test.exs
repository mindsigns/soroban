defmodule Soroban.SettingControllerTest do
  use Soroban.ConnCase

  alias Soroban.Setting
  @valid_attrs %{company_address: "some content", company_email: "some content", company_name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, setting_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing settings"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, setting_path(conn, :new)
    assert html_response(conn, 200) =~ "New setting"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, setting_path(conn, :create), setting: @valid_attrs
    assert redirected_to(conn) == setting_path(conn, :index)
    assert Repo.get_by(Setting, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, setting_path(conn, :create), setting: @invalid_attrs
    assert html_response(conn, 200) =~ "New setting"
  end

  test "shows chosen resource", %{conn: conn} do
    setting = Repo.insert! %Setting{}
    conn = get conn, setting_path(conn, :show, setting)
    assert html_response(conn, 200) =~ "Show setting"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, setting_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    setting = Repo.insert! %Setting{}
    conn = get conn, setting_path(conn, :edit, setting)
    assert html_response(conn, 200) =~ "Edit setting"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    setting = Repo.insert! %Setting{}
    conn = put conn, setting_path(conn, :update, setting), setting: @valid_attrs
    assert redirected_to(conn) == setting_path(conn, :show, setting)
    assert Repo.get_by(Setting, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    setting = Repo.insert! %Setting{}
    conn = put conn, setting_path(conn, :update, setting), setting: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit setting"
  end

  test "deletes chosen resource", %{conn: conn} do
    setting = Repo.insert! %Setting{}
    conn = delete conn, setting_path(conn, :delete, setting)
    assert redirected_to(conn) == setting_path(conn, :index)
    refute Repo.get(Setting, setting.id)
  end
end
