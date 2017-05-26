defmodule Soroban.Client do
  use Soroban.Web, :model

  schema "clients" do
    field :name, :string
    field :contact, :string
    field :address, :string
    field :email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :contact, :address, :email])
    |> validate_required([:name, :contact, :address, :email])
  end
end
