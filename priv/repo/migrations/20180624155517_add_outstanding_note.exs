defmodule Soroban.Repo.Migrations.AddOutstandingNote do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :outstanding_note, :text
    end
  end
end
