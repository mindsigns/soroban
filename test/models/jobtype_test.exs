defmodule Soroban.JobtypeTest do
  use Soroban.ModelCase

  alias Soroban.Jobtype

  @valid_attrs %{type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Jobtype.changeset(%Jobtype{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Jobtype.changeset(%Jobtype{}, @invalid_attrs)
    refute changeset.valid?
  end
end
