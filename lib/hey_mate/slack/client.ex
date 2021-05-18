defmodule HeyMate.Slack.Client do
  @slack_api_base_url "https://slack.com"

  def send_message(user_id, message) do
    with {:ok, channel_id} <- open_conversation(user_id) do
      post_message(channel_id, message)
    else
      error -> error
    end
  end

  def get_message(channel, message_ts) do
    case request(
           :get,
           "#{@slack_api_base_url}/api/conversations.replies?channel=#{channel}&ts=#{message_ts}&"
         ) do
      {:ok, %{"messages" => messages}} -> {:ok, Enum.at(messages, 0)}
      error -> error
    end
  end

  def get_message_permalink(channel, message_ts) do
    case request(
           :get,
           "#{@slack_api_base_url}/api/chat.getPermalink?" <>
             "channel=#{channel}&" <>
             "message_ts=#{message_ts}"
         ) do
      {:ok, %{"permalink" => permalink}} -> {:ok, permalink}
      error -> error
    end
  end

  def publish_view(view, user_id) do
    request(:post, "#{@slack_api_base_url}/api/views.publish", %{
      "user_id" => user_id,
      "view" => view
    })
  end

  def get_user_info(user_id) do
    case request(:get, "#{@slack_api_base_url}/api/users.info?user=#{user_id}") do
      {:ok, %{"user" => user}} -> {:ok, user}
      error -> error
    end
  end

  defp open_conversation(user_id) do
    case request(:post, "#{@slack_api_base_url}/api/conversations.open", %{"users" => user_id}) do
      {:ok, %{"channel" => %{"id" => channel_id}}} -> {:ok, channel_id}
      error -> error
    end
  end

  defp post_message(channel, message) do
    request(:post, "#{@slack_api_base_url}/api/chat.postMessage", %{
      "channel" => channel,
      "text" => message
    })
  end

  defp request(method, endpoint, body \\ %{}) do
    token = Application.fetch_env!(:hey_mate, :slack_api_key)

    case HTTPoison.request(
           method,
           endpoint,
           Poison.encode!(body),
           [
             {"Authorization", "Bearer #{token}"},
             {"Content-Type", "application/json; charset=utf-8"}
           ]
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, Poison.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end
end
