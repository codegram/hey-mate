defmodule HeyMate.Slack.RewardUserTest do
  use HeyMate.DataCase

  alias HeyMate.Slack.RewardUser

  test "is valid" do
    user = %RewardUser{} |> RewardUser.changeset(%{slack_id: "some-id"})
    assert user.valid?
  end

  test "is not valid with a blank slack_id" do
    user = %RewardUser{} |> RewardUser.changeset(%{slack_id: ""})
    refute user.valid?
  end
end
