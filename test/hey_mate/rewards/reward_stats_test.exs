defmodule HeyMate.Rewards.RewardStatsTest do
  use HeyMate.DataCase

  alias HeyMate.Rewards.Reward
  alias HeyMate.Rewards.RewardStats
  alias HeyMate.Slack.RewardUser

  describe "rewards_from_sender_sent_at/2" do
    setup [:create_sender, :create_recipient, :create_recipient2]

    test "count how many rewards have been sent at a specific date", %{
      sender: sender,
      recipient: recipient,
      recipient2: recipient2
    } do
      create_reward_at(Date.utc_today(), sender, recipient)
      create_reward_at(Date.utc_today(), sender, recipient2)
      create_reward_at(Date.utc_today() |> Date.add(-1), sender, recipient)

      assert 2 == RewardStats.rewards_from_sender_sent_at(sender, Date.utc_today())

      assert 1 ==
               RewardStats.rewards_from_sender_sent_at(sender, Date.utc_today() |> Date.add(-1))
    end
  end

  describe "total_rewards_to_recipient/2" do
    setup [:create_sender, :create_recipient, :create_recipient2]

    test "count how many rewards the recipient has received", %{
      sender: sender,
      recipient: recipient,
      recipient2: recipient2
    } do
      create_reward_at(Date.utc_today(), sender, recipient)
      create_reward_at(Date.utc_today(), sender, recipient2)
      create_reward_at(Date.utc_today() |> Date.add(-1), sender, recipient)
      create_reward_at(Date.utc_today() |> Date.add(-7), sender, recipient)

      assert 3 == RewardStats.total_rewards_to_recipient(recipient)
      assert 1 == RewardStats.total_rewards_to_recipient(recipient2)
    end
  end

  describe "total_rewards_from_sender/2" do
    setup [:create_sender, :create_recipient, :create_sender2]

    test "count how many rewards the recipient has received", %{
      sender: sender,
      recipient: recipient,
      sender2: sender2
    } do
      create_reward_at(Date.utc_today(), sender, recipient)
      create_reward_at(Date.utc_today(), sender, recipient)
      create_reward_at(Date.utc_today() |> Date.add(-7), sender, recipient)
      create_reward_at(Date.utc_today() |> Date.add(-1), sender2, recipient)

      assert 3 == RewardStats.total_rewards_from_sender(sender)
      assert 1 == RewardStats.total_rewards_from_sender(sender2)
    end
  end

  describe "sender_ranking_for_recipient/2" do
    setup [
      :create_recipient,
      :create_recipient2,
      :create_sender,
      :create_sender2,
      :create_sender3
    ]

    test "ranks the senders for a recipient", %{
      recipient: recipient,
      recipient2: recipient2,
      sender: sender,
      sender2: sender2,
      sender3: sender3
    } do
      Enum.each(1..2, fn _ -> create_reward_at(Date.utc_today(), sender, recipient) end)
      Enum.each(1..3, fn _ -> create_reward_at(Date.utc_today(), sender2, recipient) end)
      create_reward_at(Date.utc_today(), sender3, recipient)
      create_reward_at(Date.utc_today(), sender3, recipient2)

      expected = [
        %{rewards_sent: 3, sender: sender2},
        %{rewards_sent: 2, sender: sender},
        %{rewards_sent: 1, sender: sender3}
      ]

      assert expected == RewardStats.sender_ranking_for_recipient(recipient)
    end
  end

  describe "recipient_ranking_for_sender/2" do
    setup [
      :create_recipient,
      :create_recipient2,
      :create_recipient3,
      :create_sender,
      :create_sender2
    ]

    test "ranks the recipients for a sender", %{
      recipient: recipient,
      recipient2: recipient2,
      recipient3: recipient3,
      sender: sender,
      sender2: sender2
    } do
      Enum.each(1..3, fn _ -> create_reward_at(Date.utc_today(), sender, recipient) end)
      Enum.each(1..2, fn _ -> create_reward_at(Date.utc_today(), sender, recipient3) end)
      create_reward_at(Date.utc_today(), sender, recipient2)
      create_reward_at(Date.utc_today(), sender2, recipient2)

      expected = [
        %{rewards_received: 3, recipient: recipient},
        %{rewards_received: 2, recipient: recipient3},
        %{rewards_received: 1, recipient: recipient2}
      ]

      assert expected == RewardStats.recipient_ranking_for_sender(sender)
    end
  end

  defp create_sender(_context) do
    {:ok, sender: create_reward_user("sender")}
  end

  defp create_recipient(_context) do
    {:ok, recipient: create_reward_user("recipient")}
  end

  defp create_recipient2(_context) do
    {:ok, recipient2: create_reward_user("recipient2")}
  end

  defp create_sender2(_context) do
    {:ok, sender2: create_reward_user("sender2")}
  end

  defp create_recipient3(_context) do
    {:ok, recipient3: create_reward_user("recipient3")}
  end

  defp create_sender3(_context) do
    {:ok, sender3: create_reward_user("sender3")}
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
