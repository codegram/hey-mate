defmodule HeyMate.Rewards.MessageAnalyzer do
  alias HeyMate.Rewards

  @user_mention_regex ~r/<@(\w+)>/

  def message_include_reward?(message) do
    message =~ ~r/:#{Rewards.reward_emoji_name()}:/
  end

  def message_has_user_mentions?(message) do
    message =~ @user_mention_regex
  end

  def message_user_mentions(message) do
    Regex.scan(@user_mention_regex, message) |> Enum.map(&Enum.at(&1, 1)) |> Enum.uniq()
  end

  def message_rewardable?(message) do
    message_include_reward?(message) &&
      message_has_user_mentions?(message)
  end
end
