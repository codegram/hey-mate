defmodule HeyMateWeb.SlackControllerTest do
  use HeyMateWeb.ConnCase

  alias HeyMate.Rewards.Reward
  alias HeyMate.Slack.RewardUser
  alias HeyMate.Repo

  describe "challenge events" do
    test "answer the challenge webhook", %{conn: conn} do
      conn = post(conn, "/api/slack/webhooks", challenge: "miao")
      assert text_response(conn, 200) == "miao"
    end
  end

  describe "message events" do
    test "creates a reward when a message event webhook is received", %{conn: conn} do
      conn =
        post(conn, "/api/slack/webhooks",
          event: %{
            type: "message",
            text: "<@recipient> :mate:",
            user: "sender",
            channel: "channel",
            ts: "123456.0000"
          }
        )

      assert text_response(conn, 200) == "mate rewarded"
    end
  end

  describe "reaction_removed events" do
    setup [:create_sender, :create_recipient, :create_reward]

    test "revokes aan reward when a reaction_removed event webhook is received", %{
      conn: conn,
      sender: sender,
      recipient: recipient,
      reward: reward
    } do
      conn =
        post(conn, "/api/slack/webhooks",
          event: %{
            type: "reaction_removed",
            reaction: "mate",
            user: sender.slack_id,
            item_user: recipient.slack_id,
            item: %{
              channel: reward.message_channel,
              ts: reward.message_ts
            }
          }
        )

      assert text_response(conn, 200) == "mate revoked"
    end

    test "ignores a reaction_removed event webhook the emoji does is not an reward", %{
      conn: conn,
      sender: sender,
      recipient: recipient,
      reward: reward
    } do
      conn =
        post(conn, "/api/slack/webhooks",
          event: %{
            type: "reaction_removed",
            reaction: "miao",
            user: sender.slack_id,
            item_user: recipient.slack_id,
            item: %{
              channel: reward.message_channel,
              ts: reward.message_ts
            }
          }
        )

      assert text_response(conn, 200) == "no mate in the removed reaction"
    end
  end

  describe "reaction_added events" do
    test "creates a reward when a reaction_added event webhook is received", %{conn: conn} do
      conn =
        post(conn, "/api/slack/webhooks",
          event: %{
            type: "reaction_added",
            reaction: "mate",
            user: "sender",
            item_user: "recipient",
            item: %{
              channel: "channel",
              ts: "123456.0000"
            }
          }
        )

      assert text_response(conn, 200) == "mate rewarded"
    end
  end

  test "ignores unknown webhooks", %{conn: conn} do
    conn = post(conn, "/api/slack/webhooks", foo: "bar")
    assert text_response(conn, 200) == "not interested, thanks."
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
