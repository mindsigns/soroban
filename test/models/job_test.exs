defmodule Soroban.JobTest do
  use Soroban.ModelCase

  alias Soroban.Job

  @valid_attrs %{caller: "some content", charge_details: "some content", description: "some content", invoice_number: "some content", job_total: 42, job_type: "some content", reference: "some content", service: "some content", zone: "some content"}
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
