defmodule Soroban.Jobtype do
@moduledoc """
Soroban.Jobtype model
"""

  use Soroban.Web, :model

  schema "jobtypes" do
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type])
    |> validate_required([:type])
    |> unique_constraint(:type)
  end
end
