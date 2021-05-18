defmodule HeyMate.Rewards.Rewarder do
  use GenServer

  alias HeyMate.Rewards
  alias HeyMate.Rewards.RewardStats
  alias HeyMate.Rewards.MessageAnalyzer
  alias HeyMate.Slack
  alias HeyMate.Admin

  @slack_service Application.get_env(:hey_mate, :slack_service, HeyMate.Slack.Client)

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def give_reward_on_message(event) do
    GenServer.cast(__MODULE__, {:give_reward_on_message, event})
  end

  def give_reward_on_reaction(event) do
    GenServer.cast(__MODULE__, {:give_reward_on_reaction, event})
  end

  def revoke_reward_on_reaction_removed(event) do
    GenServer.cast(__MODULE__, {:revoke_reward_on_reaction_removed, event})
  end

  @impl true
  def handle_cast(
        {:give_reward_on_message, %{"text" => message, "user" => sender_slack_id} = event},
        state
      ) do
    recipient_ids = extract_recipient_ids(message)
    sender = Slack.find_reward_user_or_create_by_slack_id(sender_slack_id)

    recipient_ids
    |> Enum.map(&Slack.find_reward_user_or_create_by_slack_id/1)
    |> Enum.each(&reward_and_notify(sender, &1, message, Rewards.message_type(), event))

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:give_reward_on_reaction,
         %{"user" => sender_slack_id, "item_user" => recipient_slack_id, "item" => message_item}},
        state
      ) do
    sender = Slack.find_reward_user_or_create_by_slack_id(sender_slack_id)

    recipients_for_reaction(recipient_slack_id, message_item)
    |> Enum.map(&Slack.find_reward_user_or_create_by_slack_id(&1))
    |> Enum.map(&reward_and_notify(sender, &1, "", Rewards.reaction_type(), message_item))

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:revoke_reward_on_reaction_removed,
         %{"user" => sender_slack_id, "item_user" => recipient_slack_id, "item" => message_item}},
        state
      ) do
    sender = Slack.find_reward_user_or_create_by_slack_id(sender_slack_id)

    recipients_for_reaction(recipient_slack_id, message_item)
    |> Enum.map(&Slack.find_reward_user_or_create_by_slack_id(&1))
    |> Enum.map(&revoke_reward_and_notify(sender, &1, Rewards.reaction_type(), message_item))

    {:noreply, state}
  end

  defp extract_recipient_ids(message) do
    MessageAnalyzer.message_user_mentions(message)
  end

  defp recipients_for_reaction(recipient_id, %{"channel" => channel, "ts" => message_ts}) do
    {:ok, %{"text" => message_text}} = @slack_service.get_message(channel, message_ts)

    case MessageAnalyzer.message_rewardable?(message_text) do
      true -> MessageAnalyzer.message_user_mentions(message_text)
      _ -> [recipient_id]
    end
  end

  defp reward_and_notify(sender, recipient, text, type, %{
         "channel" => channel,
         "ts" => message_ts
       }) do
    case Rewards.give_reward(sender, recipient, text, type, channel, message_ts) do
      {:ok, _reward} ->
        {:ok, message_permalink} = @slack_service.get_message_permalink(channel, message_ts)

        rewards_sent_today = RewardStats.rewards_from_sender_sent_at(sender)
        rewards_left_today = Admin.get_current_settings().reward_limit_per_day - rewards_sent_today
        total_rewards_received = RewardStats.total_rewards_to_recipient(recipient)

        send_notification(
          sender.slack_id,
          "You <#{message_permalink}|rewarded a :#{Rewards.reward_emoji_name()}:> to <@#{
            recipient.slack_id
          }>.\n" <>
            "You sent a total of #{rewards_sent_today} :#{Rewards.reward_emoji_name()}: today! You have #{
              rewards_left_today
            } :#{Rewards.reward_emoji_name()}: left."
        )

        send_notification(
          recipient.slack_id,
          "You <#{message_permalink}|received a :#{Rewards.reward_emoji_name()}:> from <@#{
            sender.slack_id
          }>.\n" <>
            "You received a total of #{total_rewards_received} :#{Rewards.reward_emoji_name()}:!"
        )

      {:error, :self_reward} ->
        send_notification(
          sender.slack_id,
          "you cannot give a :#{Rewards.reward_emoji_name()}: to yourself"
        )

      {:error, :reached_reward_limit} ->
        send_notification(
          sender.slack_id,
          "you cannot give more :#{Rewards.reward_emoji_name()}: today!"
        )
    end
  end

  defp revoke_reward_and_notify(sender, recipient, type, %{
         "channel" => channel,
         "ts" => message_ts
       }) do
    case Rewards.revoke_reward(sender, recipient, type, channel, message_ts) do
      {:ok, _reward} ->
        {:ok, message_permalink} = @slack_service.get_message_permalink(channel, message_ts)
        rewards_sent = RewardStats.rewards_from_sender_sent_at(sender)
        rewards_left = Admin.get_current_settings().reward_limit_per_day - rewards_sent

        send_notification(
          sender.slack_id,
          "<#{message_permalink}|The :#{Rewards.reward_emoji_name()}: you gave> to <@#{
            recipient.slack_id
          }> has been revoked.\n" <>
            "You now have #{rewards_left} :#{Rewards.reward_emoji_name()}: left to give away for today."
        )

      error ->
        error
    end
  end

  defp send_notification(to_slack_id, message) do
    @slack_service.send_message(to_slack_id, message)
  end
end
