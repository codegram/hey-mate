defmodule HeyMate.Rewards.RewardTest do
  use HeyMate.DataCase

  alias HeyMate.Repo
  alias HeyMate.Slack.RewardUser
  alias HeyMate.Rewards.Reward

  setup do
    {:ok, sender} = Repo.insert(%RewardUser{slack_id: "sender"})
    {:ok, recipient} = Repo.insert(%RewardUser{slack_id: "recipient"})

    {:ok, sender: sender, recipient: recipient}
  end

  test "is valid", %{sender: sender, recipient: recipient} do
    reward =
      %Reward{}
      |> Reward.changeset(%{
        sender: sender,
        recipient: recipient,
        message: "Some message",
        type: "MESSAGE",
        message_ts: "123456.09876",
        message_channel: "CHANNEL_ID"
      })

    assert reward.valid?
  end

  test "is not valid without sender", %{recipient: recipient} do
    reward =
      %Reward{}
      |> Reward.changeset(%{
        sender: nil,
        recipient: recipient,
        message: "Some message",
        type: "MESSAGE",
        message_ts: "123456.09876",
        message_channel: "CHANNEL_ID"
      })

    refute reward.valid?
  end

  test "is not valid without recipient", %{sender: sender} do
    reward =
      %Reward{}
      |> Reward.changeset(%{
        sender: sender,
        recipient: nil,
        message: "Some message",
        type: "MESSAGE",
        message_ts: "123456.09876",
        message_channel: "CHANNEL_ID"
      })

    refute reward.valid?
  end

  test "is not valid without a type", %{sender: sender, recipient: recipient} do
    reward =
      %Reward{}
      |> Reward.changeset(%{
        sender: sender,
        recipient: recipient,
        message: "Some message",
        type: "",
        message_ts: "123456.09876",
        message_channel: "CHANNEL_ID"
      })

    refute reward.valid?
  end

  test "is not valid without a message timestamp", %{sender: sender, recipient: recipient} do
    reward =
      %Reward{}
      |> Reward.changeset(%{
        sender: sender,
        recipient: recipient,
        message: "Some message",
        type: "MESSAGE",
        message_ts: "",
        message_channel: "CHANNEL_ID"
      })

    refute reward.valid?
  end
end
