defmodule HeyMate.Slack.HomeTabBuilder do
  alias HeyMate.Slack
  alias HeyMate.Rewards
  alias HeyMate.Rewards.RewardStats

  def build_home_tab(user_id) do
    case Slack.find_reward_user_by_slack_id(user_id) do
      nil -> no_user_home_tab()
      reward_user -> home_tab_for_user(reward_user)
    end
  end

  defp no_user_home_tab() do
    %{
      type: "home",
      blocks: [
        login_section()
      ]
    }
  end

  defp home_tab_for_user(reward_user) do
    %{
      type: "home",
      blocks:
        total_rewards_section(reward_user) ++
          best_supporters_section(reward_user) ++
          cheerleader_section(reward_user)
    }
  end

  defp login_section() do
    "It looks like we don't know you yet 🤨. Please log in from the home page."
    |> mrkdwn_section
  end

  defp total_rewards_section(reward_user) do
    [
      "You sent a total of #{RewardStats.total_rewards_from_sender(reward_user)} and received a total of #{
        RewardStats.total_rewards_to_recipient(reward_user)
      } :#{Rewards.reward_emoji_name()}:"
      |> mrkdwn_section
    ]
  end

  defp best_supporters_section(reward_user) do
    [
      header("Your best supporters")
      | RewardStats.sender_ranking_for_recipient(reward_user)
        |> Enum.with_index()
        |> Enum.map(&supporter_context(&1))
    ]
  end

  defp cheerleader_section(reward_user) do
    [
      header("You are a cheerleader to")
      | RewardStats.recipient_ranking_for_sender(reward_user)
        |> Enum.with_index()
        |> Enum.map(&cheerleader_context(&1))
    ]
  end

  defp mrkdwn_section(text) do
    %{
      type: "section",
      text: %{
        type: "mrkdwn",
        text: text
      }
    }
  end

  defp header(text) do
    %{
      type: "header",
      text: %{
        type: "plain_text",
        text: text,
        emoji: true
      }
    }
  end

  defp supporter_context({sender_ranking, position}) do
    {:ok, user_info} = Slack.get_user_info(sender_ranking[:sender].slack_id)

    %{
      type: "context",
      elements: [
        %{
          type: "mrkdwn",
          text: emoji_for_position(position + 1)
        },
        %{
          type: "image",
          image_url: user_info["profile"]["image_512"],
          alt_text: "#{user_info["profile"]["real_name"]} profile picture"
        },
        %{
          type: "mrkdwn",
          text:
            "<@#{user_info["id"]}> rewarder you #{sender_ranking[:rewards_sent]} :#{
              Rewards.reward_emoji_name()
            }:"
        }
      ]
    }
  end

  defp cheerleader_context({recipient_ranking, position}) do
    {:ok, user_info} = Slack.get_user_info(recipient_ranking[:recipient].slack_id)

    %{
      type: "context",
      elements: [
        %{
          type: "mrkdwn",
          text: emoji_for_position(position + 1)
        },
        %{
          type: "image",
          image_url: user_info["profile"]["image_512"],
          alt_text: "Profile picture of #{user_info["profile"]["real_name"]}"
        },
        %{
          type: "mrkdwn",
          text:
            "<@#{user_info["id"]}> received #{recipient_ranking[:rewards_received]} :#{
              Rewards.reward_emoji_name()
            }: from you!"
        }
      ]
    }
  end

  defp emoji_for_position(position) do
    case position do
      1 -> ":first_place_medal:"
      2 -> ":second_place_medal:"
      3 -> ":third_place_medal:"
      _ -> ""
    end
  end
end
