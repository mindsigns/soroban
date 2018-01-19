defmodule Soroban.SettingTest do
  use Soroban.ModelCase

  alias Soroban.Setting

  @valid_attrs %{
    company_address: "some content",
    company_email: "some content",
    company_name: "some content"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Setting.changeset(%Setting{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Setting.changeset(%Setting{}, @invalid_attrs)
    refute changeset.valid?
  end
end
