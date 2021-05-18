defmodule HeyMate.Admin.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :reward_emoji_name, :string
    field :reward_limit_per_day, :integer

    timestamps()
  end

  def changeset(settings, attrs \\ %{}) do
    settings
    |> cast(attrs, [:reward_emoji_name, :reward_limit_per_day])
    |> validate_required([:reward_emoji_name, :reward_limit_per_day])
    |> validate_number(:reward_limit_per_day, greater_than_or_equal_to: 0)
  end
end
