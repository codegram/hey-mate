defmodule HeyMate.Admin.SettingsTest do
  use HeyMate.DataCase

  alias HeyMate.Admin.Settings

  test "is valid" do
    settings =
      %Settings{} |> Settings.changeset(%{reward_emoji_name: "mate", reward_limit_per_day: 10})

    assert settings.valid?
  end

  test "is not valid without reward_emoji_name" do
    settings =
      %Settings{} |> Settings.changeset(%{reward_emoji_name: nil, reward_limit_per_day: 10})

    refute settings.valid?
  end

  test "is not valid without reward_limit_per_day" do
    settings =
      %Settings{} |> Settings.changeset(%{reward_emoji_name: "mate", reward_limit_per_day: nil})

    refute settings.valid?
  end

  test "is not valid with a negative reward_limit_per_day" do
    settings =
      %Settings{} |> Settings.changeset(%{reward_emoji_name: "mate", reward_limit_per_day: -10})

    refute settings.valid?
  end
end
