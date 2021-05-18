defmodule HeyMate.Repo.Migrations.RewardsAddMessageColumn do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add :message, :text
    end
  end
end
