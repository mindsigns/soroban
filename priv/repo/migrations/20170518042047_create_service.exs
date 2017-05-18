defmodule Soroban.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :type, :string

      timestamps()
    end

  end
end
