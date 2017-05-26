defmodule Soroban.JobTest do
  use Soroban.ModelCase

  alias Soroban.Job

  @valid_attrs %{caller: "some content", date: %{day: 17, month: 4, year: 2010}, description: "some content", details: "some content", reference: "some content", service: "some content", total: "120.5", type: "some content", zone: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Job.changeset(%Job{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Job.changeset(%Job{}, @invalid_attrs)
    refute changeset.valid?
  end
end
