defmodule Soroban.Repo.Migrations.AddFieldToSettings do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :note, :text
    end
  end
end
