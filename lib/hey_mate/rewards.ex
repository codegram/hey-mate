defmodule HeyMate.Rewards do
  @moduledoc """
  The Rewards context.
  """
  import Ecto.Query

  alias HeyMate.Repo
  alias HeyMate.Admin
  alias HeyMate.Rewards.Reward
  alias HeyMate.Rewards.RewardStats

  @message_type "MESSAGE"
  @reaction_type "REACTION"

  def reward_emoji_name do
    Admin.get_current_settings().reward_emoji_name
  end

  def message_type, do: @message_type
  def reaction_type, do: @reaction_type

  def give_reward(sender, sender, _message, _type, _channel, _message_ts),
    do: {:error, :self_reward}

  def give_reward(sender, recipient, message, type, channel, message_ts) do
    rewards_sent = RewardStats.rewards_from_sender_sent_at(sender)
    rewards_limit_per_day = Admin.get_current_settings().reward_limit_per_day

    maybe_give_reward(
      rewards_limit_per_day - rewards_sent,
      sender,
      recipient,
      message,
      type,
      channel,
      message_ts
    )
  end

  def revoke_reward(sender, recipient, type, channel, message_ts) do
    case reward_exists?(sender, recipient, type, channel, message_ts) do
      true -> destroy_rewards(sender, recipient, type, channel, message_ts)
      _ -> {:ok, :reward_not_found}
    end
  end

  def maybe_give_reward(0, _sender, _recipient, _message, _type, _channel, _message_ts),
    do: {:error, :reached_reward_limit}

  def maybe_give_reward(_remaining, sender, recipient, message, type, channel, message_ts) do
    %Reward{}
    |> Reward.changeset(%{
      sender: sender,
      recipient: recipient,
      message: message,
      type: type,
      message_channel: channel,
      message_ts: message_ts
    })
    |> Repo.insert()
  end

  defp reward_exists?(sender, recipient, type, message_channel, message_ts) do
    reward_query(sender, recipient, type, message_channel, message_ts)
    |> Repo.exists?()
  end

  defp destroy_rewards(sender, recipient, type, message_channel, message_ts) do
    case reward_query(sender, recipient, type, message_channel, message_ts)
         |> Repo.delete_all() do
      {num_deleted, nil} -> {:ok, num_deleted}
      error -> error
    end
  end

  defp reward_query(sender, recipient, type, message_channel, message_ts) do
    from x in Reward,
      where:
        x.sender_id == ^sender.id and
          x.recipient_id == ^recipient.id and
          x.type == ^type and
          x.message_channel == ^message_channel and
          x.message_ts == ^message_ts
  end
end
