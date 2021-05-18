defmodule HeyMate.SlackTest do
  use HeyMate.DataCase

  alias HeyMate.Repo
  alias HeyMate.Slack
  alias HeyMate.Slack.RewardUser

  describe "find_reward_user_or_create_by_slack_id/1" do
    test "creates the user if they doesn't exist" do
      Slack.find_reward_user_or_create_by_slack_id("some_id")
      assert 1 == Repo.aggregate(RewardUser, :count)
    end

    test "doesn't create the user if they already exist" do
      Repo.insert(%RewardUser{slack_id: "some_id"})
      Slack.find_reward_user_or_create_by_slack_id("some_id")
      assert 1 == Repo.aggregate(RewardUser, :count)
    end
  end

  describe "parse_event/1" do
    test "rewards when message contains reward emoji" do
      assert {:ok, "mate rewarded"} ==
               Slack.parse_event(%{
                 "type" => "message",
                 "text" => "<@recipient> :mate:",
                 "user" => "sender",
                 "channel" => "channel",
                 "ts" => "123456.0000"
               })
    end

    test "rewards when reactions is reward emoji" do
      assert {:ok, "mate rewarded"} ==
               Slack.parse_event(%{
                 "type" => "reaction_added",
                 "reaction" => "mate",
                 "user" => "sender",
                 "item_user" => "recipient",
                 "item" => %{
                   "channel" => "channel",
                   "ts" => "123456.0000"
                 }
               })
    end

    test "does not reward when message does not contain reward emoji" do
      assert {:ok, "no mate in the message"} ==
               Slack.parse_event(%{
                 "type" => "message",
                 "text" => "<@recipient> :miao:",
                 "user" => "sender",
                 "channel" => "channel",
                 "ts" => "123456.0000"
               })
    end

    test "does not reward when reaction is not reward emoji" do
      assert {:ok, "no mate in the reaction"} ==
               Slack.parse_event(%{
                 "type" => "reaction_added",
                 "reaction" => "miao",
                 "user" => "sender",
                 "item_user" => "recipient",
                 "item" => %{
                   "channel" => "channel",
                   "ts" => "123456.0000"
                 }
               })
    end

    test "revokes reward when reaction removed is reward emoji" do
      assert {:ok, "mate revoked"} ==
               Slack.parse_event(%{
                 "type" => "reaction_removed",
                 "reaction" => "mate",
                 "user" => "sender",
                 "item_user" => "recipient",
                 "item" => %{
                   "channel" => "channel",
                   "ts" => "123456.0000"
                 }
               })
    end

    test "publishes the home page when the event is app_home_opened and the tab is home" do
      assert {:ok, "home tab published"} ==
               Slack.parse_event(%{
                 "type" => "app_home_opened",
                 "tab" => "home",
                 "user" => "sender",
                 "ts" => "123456.0000"
               })
    end

    test "ignores the event whenthe event is app_home_opened and the tab is not home" do
      assert {:ok, :event_ignored} ==
               Slack.parse_event(%{
                 "type" => "app_home_opened",
                 "tab" => "miao",
                 "user" => "sender",
                 "ts" => "123456.0000"
               })
    end

    test "ignores the reaction_removed event when the reaction is not the reward emoji" do
      assert {:ok, "no mate in the removed reaction"} ==
               Slack.parse_event(%{
                 "type" => "reaction_removed",
                 "reaction" => "miao",
                 "user" => "sender",
                 "item_user" => "recipient",
                 "item" => %{
                   "channel" => "channel",
                   "ts" => "123456.0000"
                 }
               })
    end

    test "ignores other events" do
      assert {:ok, :event_ignored} == Slack.parse_event(%{"type" => "miao"})
    end
  end
end
