defmodule HeyMate.Repo.Migrations.CreateRewards do
  use Ecto.Migration

  def change do
    create table(:rewards) do
      timestamps()
    end
  end
end
