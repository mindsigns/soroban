defmodule Soroban.Repo.Migrations.UpdateFeesAdvDefault do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      modify :fees_advanced, :integer, default: 0
  end
  end
end
