defmodule Soroban.Repo.Migrations.CreateJobtype do
  use Ecto.Migration

  def change do
    create table(:jobtypes) do
      add :type, :string

      timestamps()
    end

  end
end
