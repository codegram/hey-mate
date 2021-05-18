defmodule HeyMate.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :reward_emoji_name, :string, null: false, default: "mate_drink"
      add :reward_limit_per_day, :integer, null: false, default: 10

      timestamps()
    end
  end
end
