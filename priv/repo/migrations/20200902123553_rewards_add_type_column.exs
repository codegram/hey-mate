defmodule HeyMate.Repo.Migrations.RewardsAddTypeColumn do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add :type, :string, default: "MESSAGE"
    end
  end
end
