defmodule HeyMate.Slack.RewardUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias HeyMate.Rewards.Reward

  schema "reward_users" do
    field :slack_id, :string
    has_many :sent_rewards, Reward, foreign_key: :sender_id
    has_many :received_rewards, Reward, foreign_key: :recipient_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:slack_id])
    |> validate_required([:slack_id])
  end
end
