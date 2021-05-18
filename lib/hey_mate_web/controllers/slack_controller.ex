defmodule HeyMateWeb.SlackController do
  use HeyMateWeb, :controller

  alias HeyMate.Slack

  def webhooks(conn, %{"challenge" => challenge}) do
    text(conn, challenge)
  end

  def webhooks(conn, %{"event" => event}) do
    case Slack.parse_event(event) do
      {:ok, response} -> conn |> text(response)
      {:error, message} -> conn |> resp(:internal_server_error, message)
    end
  end

  def webhooks(conn, _) do
    text(conn, "not interested, thanks.")
  end
end
