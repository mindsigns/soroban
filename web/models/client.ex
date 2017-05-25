defmodule Soroban.Client do
  use Soroban.Web, :model

  schema "clients" do
    field :name, :string
    field :address, :string
    field :email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :address, :email])
    |> validate_required([:name, :address, :email])
  end
end
