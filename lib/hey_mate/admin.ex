defmodule HeyMate.Admin do
  @moduledoc """
  The Admin context.
  """

  alias HeyMate.Repo
  alias HeyMate.Admin.Settings

  @default_reward_emoji_name "mate"
  @default_reward_limit_per_day 10

  def update_settings(settings) do
    get_current_settings()
    |> Settings.changeset(settings)
    |> Repo.update()
  end

  def get_current_settings do
    case Repo.one(Settings) do
      nil ->
        %Settings{}
        |> Settings.changeset(%{
          reward_emoji_name: @default_reward_emoji_name,
          reward_limit_per_day: @default_reward_limit_per_day
        })
        |> Repo.insert!()

      settings ->
        settings
    end
  end
end
