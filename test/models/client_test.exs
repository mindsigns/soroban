defmodule Soroban.ClientTest do
  use Soroban.ModelCase

  alias Soroban.Client

  @valid_attrs %{address: "some content", email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Client.changeset(%Client{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Client.changeset(%Client{}, @invalid_attrs)
    refute changeset.valid?
  end
end
