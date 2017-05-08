defmodule Soroban.User do
  use Soroban.Web, :model

  schema "users" do
    field :email, :string
    field :hashed_confirmation_token, :string
    field :confirmed_at, Ecto.DateTime
    field :unconfirmed_email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :hashed_confirmation_token, :confirmed_at, :unconfirmed_email])
    |> validate_required([:email])
    |> downcase_email
    |> unique_constraint(:email)
  end

  def permissions(_user_id) do
    Application.get_env(:sentinel, :permissions)
  end

  defp downcase_email(changeset) do
    email = get_change(changeset, :email)
    if is_nil(email) do
      changeset
    else
      put_change(changeset, :email, String.downcase(email))
    end
  end
end
