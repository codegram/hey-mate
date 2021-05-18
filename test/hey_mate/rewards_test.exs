defmodule HeyMate.RewardsTest do
  use HeyMate.DataCase

  alias HeyMate.Repo
  alias HeyMate.Rewards
  alias HeyMate.Rewards.Reward
  alias HeyMate.Slack.RewardUser
  alias HeyMate.Admin.Settings

  describe "give_reward/6" do
    setup [:create_sender, :create_recipient]

    test "creates a reward when sender and receiver are different", %{
      sender: sender,
      recipient: recipient
    } do
      {:ok, reward} =
        Rewards.give_reward(
          sender,
          recipient,
          "Some message",
          "MESSAGE",
          "CHANNEL_ID",
          "12345.09876"
        )

      assert reward.sender == sender
      assert reward.recipient == recipient
      assert reward.message == "Some message"
      assert reward.type == "MESSAGE"
    end

    test "doesn't create a reward when sender and receiver are the same user", %{
      sender: sender
    } do
      assert {:error, :self_reward} ==
               Rewards.give_reward(
                 sender,
                 sender,
                 "Some message",
                 "MESSAGE",
                 "CHANNEL_ID",
                 "12345.09876"
               )
    end

    test "doesn't create a reward when sender has reached the limit", %{
      sender: sender,
      recipient: recipient
    } do
      %Settings{}
      |> Settings.changeset(%{reward_emoji_name: "mate", reward_limit_per_day: 1})
      |> Repo.insert!()

      create_reward_at(Date.utc_today(), sender, recipient)

      assert {:error, :reached_reward_limit} ==
               Rewards.give_reward(
                 sender,
                 recipient,
                 "Some message",
                 "MESSAGE",
                 "CHANNEL_ID",
                 "12345.09876"
               )
    end
  end

  describe "revoke_reward/5" do
    setup [:create_sender, :create_recipient, :create_reward]

    test "deletes the reward when the params match", %{
      sender: sender,
      recipient: recipient,
      reward: reward
    } do
      assert {:ok, 1} =
               Rewards.revoke_reward(
                 sender,
                 recipient,
                 "REACTION",
                 reward.message_channel,
                 reward.message_ts
               )
    end

    test "returns reward_not_found when no reward matches the params", %{
      sender: sender,
      recipient: recipient,
      reward: reward
    } do
      assert {:ok, :reward_not_found} ==
               Rewards.revoke_reward(
                 sender,
                 recipient,
                 "REACTION",
                 reward.message_channel,
                 "123.4567"
               )
    end
  end

  defp create_sender(_context) do
    {:ok, sender: create_reward_user("sender")}
  end

  defp create_recipient(_context) do
    {:ok, recipient: create_reward_user("recipient")}
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

  defp create_reward(context) do
    reward_params = %{
      sender_id: context[:sender].id,
      recipient_id: context[:recipient].id,
      type: "REACTION",
      message_channel: "C0G9QF9GZ",
      message_ts: "1360782400.498405"
    }

    {:ok, reward: Repo.insert!(struct(Reward, reward_params))}
  end
end
