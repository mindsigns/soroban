defmodule Welcome.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :username, :string
      add :password_hash, :string
      add :confirmed_at, :utc_datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :utc_datetime
      add :reset_token, :string
      add :reset_sent_at, :utc_datetime

      timestamps()
    end

    create unique_index :users, [:email]
  end
end
