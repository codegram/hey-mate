defmodule HeyMate.Repo.Migrations.RenameUsersToRewardUsers do
  use Ecto.Migration

  def change do
    rename table(:users), to: table(:reward_users)
  end
end
