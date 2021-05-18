defmodule HeyMate.Test.Stub.Slack do
  def send_message(_user, message) do
    {:ok, message}
  end

  def get_message_permalink(_channel, _ts) do
    {:ok, "permalink"}
  end

  def get_message(_channel, _ts) do
    {:ok, %{"text" => "text"}}
  end

  def publish_view(view, _user_id) do
    {:ok, view}
  end

  def get_user_info(user_id) do
    {:ok, user_id}
  end
end
