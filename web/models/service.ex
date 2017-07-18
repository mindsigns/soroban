defmodule Soroban.Service do
@moduledoc """
Soroban.Service model
"""

  use Soroban.Web, :model

  schema "services" do
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
  end
end
