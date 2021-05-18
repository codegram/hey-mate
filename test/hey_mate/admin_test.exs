defmodule HeyMate.AdminTest do
  use HeyMate.DataCase

  alias HeyMate.Repo
  alias HeyMate.Admin
  alias HeyMate.Admin.Settings

  describe "get_current_settings/0" do
    test "creates default settings when they doesn't exist" do
      settings = Admin.get_current_settings()

      assert settings.reward_emoji_name == "mate"
      assert settings.reward_limit_per_day == 10
    end

    test "return the current settings" do
      %Settings{reward_emoji_name: "carrot", reward_limit_per_day: 5} |> Repo.insert!()
      settings = Admin.get_current_settings()

      assert settings.reward_emoji_name == "carrot"
      assert settings.reward_limit_per_day == 5
    end
  end

  describe "update_settings/1" do
    test "update the current settings" do
      %Settings{reward_emoji_name: "sushi", reward_limit_per_day: 5} |> Repo.insert!()

      {:ok, settings} =
        Admin.update_settings(%{reward_emoji_name: "pineapple", reward_limit_per_day: 1})

      assert settings.reward_emoji_name == "pineapple"
      assert settings.reward_limit_per_day == 1
    end
  end
end
