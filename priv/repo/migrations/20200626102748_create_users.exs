defmodule HeyMate.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :slack_id, :string

      timestamps()
    end
  end
end
