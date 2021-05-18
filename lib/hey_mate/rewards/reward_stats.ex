defmodule HeyMate.Rewards.RewardStats do
  import Ecto.Query
  alias HeyMate.Repo
  alias HeyMate.Rewards.Reward
  alias HeyMate.Slack.RewardUser

  def rewards_from_sender_sent_at(sender, sent_at \\ Date.utc_today()) do
    query =
      from b in Reward,
        where: b.sender_id == ^sender.id and fragment("?::date", b.inserted_at) == ^sent_at

    Repo.aggregate(query, :count)
  end

  def total_rewards_from_sender(sender) do
    query =
      from b in Reward,
        where: b.sender_id == ^sender.id

    Repo.aggregate(query, :count)
  end

  def total_rewards_to_recipient(recipient) do
    query =
      from b in Reward,
        where: b.recipient_id == ^recipient.id

    Repo.aggregate(query, :count)
  end

  def sender_ranking_for_recipient(recipient) do
    RewardUser
    |> join(:left, [sender], sent_reward in assoc(sender, :sent_rewards))
    |> where([_sender, sent_reward], sent_reward.recipient_id == ^recipient.id)
    |> group_by([sender, _sent_reward], sender.id)
    |> select([sender, sent_reward], %{
      sender: sender,
      rewards_sent: fragment("count(?) as rewards_sent", sender.id)
    })
    |> order_by([_sender, _sent_reward], desc: fragment("rewards_sent"))
    |> limit(3)
    |> Repo.all()
  end

  def recipient_ranking_for_sender(sender) do
    RewardUser
    |> join(:left, [recipient], received_reward in assoc(recipient, :received_rewards))
    |> where([_recipient, received_reward], received_reward.sender_id == ^sender.id)
    |> group_by([recipient, _received_reward], recipient.id)
    |> select([recipient, received_reward], %{
      recipient: recipient,
      rewards_received: fragment("count(?) as rewards_received", recipient.id)
    })
    |> order_by([_recipient, _received_reward], desc: fragment("rewards_received"))
    |> limit(3)
    |> Repo.all()
  end
end
