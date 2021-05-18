defmodule HeyMate.Repo.Migrations.AddUsersToRewards do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add :sender_id, references(:users)
      add :recipient_id, references(:users)
    end
  end
end
