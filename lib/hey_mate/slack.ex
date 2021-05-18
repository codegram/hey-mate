defmodule HeyMate.Slack do
  @moduledoc """
  The Slack context.
  """

  alias HeyMate.Repo
  alias HeyMate.Rewards
  alias HeyMate.Slack.RewardUser
  alias HeyMate.Slack.HomeTabBuilder
  alias HeyMate.Rewards.Rewarder
  alias HeyMate.Rewards.MessageAnalyzer

  @slack_service Application.get_env(:hey_mate, :slack_service, HeyMate.Slack.Client)

  def parse_event(%{"type" => "message", "text" => message} = event) do
    MessageAnalyzer.message_include_reward?(message)
    |> maybe_reward_on_message(event)
  end

  def parse_event(%{"type" => "reaction_added", "reaction" => reaction} = event) do
    reaction_include_reward?(reaction)
    |> maybe_reward_on_reaction(event)
  end

  def parse_event(%{"type" => "reaction_removed", "reaction" => reaction} = event) do
    reaction_include_reward?(reaction)
    |> maybe_revoke_on_reaction_removed(event)
  end

  def parse_event(%{"type" => "app_home_opened", "tab" => "home", "user" => user_slack_id}) do
    case publish_home_tab(user_slack_id) do
      {:ok, _response} -> {:ok, "home tab published"}
      _ -> {:error, "something went wrong"}
    end
  end

  def parse_event(_event) do
    {:ok, :event_ignored}
  end

  def find_reward_user_or_create_by_slack_id(slack_id) do
    case find_reward_user_by_slack_id(slack_id) do
      nil ->
        %RewardUser{}
        |> RewardUser.changeset(%{slack_id: slack_id})
        |> Repo.insert!()

      reward_user ->
        reward_user
    end
  end

  def get_user_info(slack_id) do
    @slack_service.get_user_info(slack_id)
  end

  def find_reward_user_by_slack_id(slack_id) do
    Repo.get_by(RewardUser, %{slack_id: slack_id})
  end

  defp maybe_reward_on_message(true, event) do
    case Rewarder.give_reward_on_message(event) do
      :ok -> {:ok, "#{Rewards.reward_emoji_name()} rewarded"}
      _ -> {:error, "something went wrong"}
    end
  end

  defp maybe_reward_on_message(false, _event),
    do: {:ok, "no #{Rewards.reward_emoji_name()} in the message"}

  defp maybe_reward_on_reaction(true, event) do
    case Rewarder.give_reward_on_reaction(event) do
      :ok -> {:ok, "#{Rewards.reward_emoji_name()} rewarded"}
      _ -> {:error, "something went wrong"}
    end
  end

  defp maybe_reward_on_reaction(false, _event),
    do: {:ok, "no #{Rewards.reward_emoji_name()} in the reaction"}

  defp maybe_revoke_on_reaction_removed(true, event) do
    case Rewarder.revoke_reward_on_reaction_removed(event) do
      :ok -> {:ok, "#{Rewards.reward_emoji_name()} revoked"}
      _ -> {:error, "something went wrong"}
    end
  end

  defp maybe_revoke_on_reaction_removed(false, _event),
    do: {:ok, "no #{Rewards.reward_emoji_name()} in the removed reaction"}

  defp reaction_include_reward?(reaction) do
    reaction == Rewards.reward_emoji_name()
  end

  defp publish_home_tab(slack_user_id) do
    HomeTabBuilder.build_home_tab(slack_user_id)
    |> @slack_service.publish_view(slack_user_id)
  end
end
