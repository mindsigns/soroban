defmodule Soroban.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string
      add :contact, :string
      add :address, :text
      add :email, :string

      timestamps()
    end

  end
end
