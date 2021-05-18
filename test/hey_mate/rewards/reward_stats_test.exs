defmodule HeyMate.Rewards.RewardStatsTest do
  use HeyMate.DataCase

  alias HeyMate.Rewards.Reward
  alias HeyMate.Rewards.RewardStats
  alias HeyMate.Slack.RewardUser

  describe "rewards_from_sender_sent_at/2" do
    setup [:create_sender, :create_recipient, :create_another_recipient]

    test "count how many rewards have been sent at a specific date", %{
      sender: sender,
      recipient: recipient,
      another_recipient: another_recipient
    } do
      create_reward_at(Date.utc_today(), sender, recipient)
      create_reward_at(Date.utc_today(), sender, another_recipient)
      create_reward_at(Date.utc_today() |> Date.add(-1), sender, recipient)

      assert 2 == RewardStats.rewards_from_sender_sent_at(sender, Date.utc_today())

      assert 1 ==
               RewardStats.rewards_from_sender_sent_at(sender, Date.utc_today() |> Date.add(-1))
    end
  end

  defp create_sender(_context) do
    {:ok, sender: create_reward_user("sender")}
  end

  defp create_recipient(_context) do
    {:ok, recipient: create_reward_user("recipient")}
  end

  defp create_another_recipient(_context) do
    {:ok, another_recipient: create_reward_user("another_recipient")}
  end

  defp create_reward_user(slack_id) do
    Repo.insert!(%RewardUser{slack_id: slack_id})
  end

  defp create_reward_at(inserted_at, sender, recipient) do
    {:ok, inserted_at} = inserted_at |> NaiveDateTime.new(~T[00:00:00])

    %Reward{}
    |> Reward.changeset(%{
      sender: sender,
      recipient: recipient,
      type: "MESSAGE",
      message_ts: "1234",
      message_channel: "some_channel"
    })
    |> put_change(:inserted_at, inserted_at)
    |> Repo.insert!()
  end
end
