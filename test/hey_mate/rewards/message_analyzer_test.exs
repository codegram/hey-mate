defmodule HeyMate.Rewards.MessageAnalyzerTest do
  use HeyMate.DataCase

  alias HeyMate.Rewards.MessageAnalyzer

  describe "message_include_reward/1" do
    test "returns true when the reward is present" do
      assert MessageAnalyzer.message_include_reward?("here's a :mate:!")
    end

    test "returns false when the reward is NOT present" do
      refute MessageAnalyzer.message_include_reward?("I'm hungry")
    end
  end

  describe "message_has_user_mentions?/1" do
    test "returns true when only 1 user mention is present" do
      assert MessageAnalyzer.message_has_user_mentions?("<@miao> here's a :mate:!")
    end

    test "returns true when multiple user mentions are present" do
      assert MessageAnalyzer.message_has_user_mentions?(":mate: to <@miao> and <@bau>!")
    end

    test "returns false when NO user mentions are present" do
      refute MessageAnalyzer.message_has_user_mentions?("I'm hungry")
    end
  end

  describe "message_rewardable?/1" do
    test "returns true when mention and reward are present" do
      assert MessageAnalyzer.message_rewardable?("<@miao> here's a :mate:!")
    end

    test "returns false when only mention is present" do
      refute MessageAnalyzer.message_rewardable?("<@miao>")
    end

    test "returns false when only reward is present" do
      refute MessageAnalyzer.message_rewardable?("I'm hungry :mate:")
    end
  end

  describe "message_user_mentions/1" do
    test "returns the user handle when one present" do
      assert ["miao"] == MessageAnalyzer.message_user_mentions("<@miao> here's a :mate:!")
    end

    test "returns all user handles when multiple present" do
      assert ["miao", "bau"] ==
               MessageAnalyzer.message_user_mentions("<@miao> here's a :mate:! <@bau>")
    end

    test "returns unique user handles when duplicated are present" do
      assert ["miao", "bau"] ==
               MessageAnalyzer.message_user_mentions(
                 "<@miao><@bau><@miao> here's a :mate:! <@bau><@miao>"
               )
    end

    test "returns no user handles when none present" do
      assert MessageAnalyzer.message_user_mentions("I'm hungry") |> Enum.empty?()
    end
  end
end
