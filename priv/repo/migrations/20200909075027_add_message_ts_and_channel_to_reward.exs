defmodule HeyMate.Repo.Migrations.AddMessageTsAndChannelToReward do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add :message_ts, :string
      add :message_channel, :string
    end
  end
end
