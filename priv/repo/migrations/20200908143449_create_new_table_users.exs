defmodule HeyMate.Repo.Migrations.CreateNewTableUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :role, :string
      add :reward_user_id, references(:reward_users)

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
