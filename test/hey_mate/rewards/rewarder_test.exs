defmodule HeyMate.Rewards.RewardAwarderTest do
  use ExUnit.Case, async: true

  alias HeyMate.Rewards.Rewarder
  alias HeyMate.Rewards.Reward
  alias HeyMate.Slack.RewardUser
  alias HeyMate.Repo

  setup do
    # Avoids raising error when DB is accessed by unregistered processes
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    server_pid =
      case start_supervised(Rewarder) do
        {:ok, pid} -> pid
        {:error, {{:already_started, pid}, _}} -> pid
      end

    {:ok, server: server_pid}
  end

  describe "give_reward_on_message/1" do
    test "creates one reward and 2 users when the message has one recipient", %{
      server: server_pid
    } do
      assert :ok ==
               Rewarder.give_reward_on_message(%{
                 "type" => "message",
                 "text" => "<@recipient> :mate:",
                 "user" => "sender",
                 "channel" => "channel",
                 "ts" => "123456.0000"
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 2 == Repo.aggregate(RewardUser, :count)
      assert 1 == Repo.aggregate(Reward, :count)
    end

    test "does not create the users if they already exist", %{server: server_pid} do
      create_reward_user("recipient")
      create_reward_user("sender")
      assert 2 == Repo.aggregate(RewardUser, :count)

      assert :ok ==
               Rewarder.give_reward_on_message(%{
                 "type" => "message",
                 "text" => "<@recipient> :mate:",
                 "user" => "sender",
                 "channel" => "channel",
                 "ts" => "123456.0000"
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 2 == Repo.aggregate(RewardUser, :count)
      assert 1 == Repo.aggregate(Reward, :count)
    end

    test "creates multiple rewards when the message include two recipients", %{
      server: server_pid
    } do
      assert :ok ==
               Rewarder.give_reward_on_message(%{
                 "type" => "message",
                 "text" => "<@recipient_1> <@recipient_2> :mate:",
                 "user" => "sender",
                 "channel" => "channel",
                 "ts" => "123456.0000"
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 3 == Repo.aggregate(RewardUser, :count)
      assert 2 == Repo.aggregate(Reward, :count)
    end

    test "doesn't create a reward when sender and recipient are the same user", %{
      server: server_pid
    } do
      assert :ok ==
               Rewarder.give_reward_on_message(%{
                 "type" => "message",
                 "text" => "<@sender> :mate:",
                 "user" => "sender",
                 "channel" => "channel",
                 "ts" => "123456.0000"
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 1 == Repo.aggregate(RewardUser, :count)
      assert 0 == Repo.aggregate(Reward, :count)
    end
  end

  describe "give_reward_on_reaction/1" do
    test "creates a reward with a reaction", %{server: server_pid} do
      assert :ok ==
               Rewarder.give_reward_on_reaction(%{
                 "type" => "reaction_added",
                 "reaction" => "mate",
                 "user" => "sender",
                 "item_user" => "recipient",
                 "item" => %{
                   "channel" => "channel",
                   "ts" => "123456.0000"
                 }
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 2 == Repo.aggregate(RewardUser, :count)
      assert 1 == Repo.aggregate(Reward, :count)
    end

    test "doesn't create a reward when the reaction is from the message sender", %{
      server: server_pid
    } do
      assert :ok ==
               Rewarder.give_reward_on_reaction(%{
                 "type" => "reaction_added",
                 "reaction" => "mate",
                 "user" => "sender",
                 "item_user" => "sender",
                 "item" => %{
                   "channel" => "channel",
                   "ts" => "123456.0000"
                 }
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 1 == Repo.aggregate(RewardUser, :count)
      assert 0 == Repo.aggregate(Reward, :count)
    end
  end

  describe "revoke_reward_on_reaction_removed/1" do
    setup [:create_sender, :create_recipient, :create_reward]

    test "deletes the reward when it exists", %{
      server: server_pid,
      reward: reward,
      sender: sender,
      recipient: recipient
    } do
      assert 1 == Repo.aggregate(Reward, :count)

      assert :ok ==
               Rewarder.revoke_reward_on_reaction_removed(%{
                 "type" => "reaction_removed",
                 "user" => sender.slack_id,
                 "reaction" => "mate",
                 "item_user" => recipient.slack_id,
                 "item" => %{
                   "type" => "message",
                   "channel" => reward.message_channel,
                   "ts" => reward.message_ts
                 },
                 "event_ts" => "1360782804.083113"
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 0 == Repo.aggregate(Reward, :count)
    end

    test "does not delete any reward when it the params passed do not match any", %{
      server: server_pid,
      reward: reward,
      sender: sender,
      recipient: recipient
    } do
      assert 1 == Repo.aggregate(Reward, :count)

      assert :ok ==
               Rewarder.revoke_reward_on_reaction_removed(%{
                 "type" => "reaction_removed",
                 "user" => sender.slack_id,
                 "reaction" => "thumbsup",
                 "item_user" => recipient.slack_id,
                 "item" => %{
                   "type" => "message",
                   "channel" => "OTHER_CHANNEL",
                   "ts" => reward.message_ts
                 },
                 "event_ts" => "1360782804.083113"
               })

      # Waits for the server to finish the task
      :sys.get_state(server_pid)

      assert 1 == Repo.aggregate(Reward, :count)
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
