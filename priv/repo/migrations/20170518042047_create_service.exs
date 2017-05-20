defmodule Soroban.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :type, :string

      timestamps()
    end
    create unique_index(:services, [:type])
  end
end
