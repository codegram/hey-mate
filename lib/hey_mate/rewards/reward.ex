defmodule HeyMate.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  alias HeyMate.Slack.RewardUser

  schema "rewards" do
    belongs_to :sender, RewardUser, foreign_key: :sender_id
    belongs_to :recipient, RewardUser, foreign_key: :recipient_id
    field :message, :string
    field :type, :string
    field :message_ts, :string
    field :message_channel, :string

    timestamps()
  end

  def changeset(reward, %{sender: sender, recipient: recipient} = attrs) do
    reward
    |> cast(attrs, [:message, :type, :message_ts, :message_channel])
    |> put_assoc(:recipient, recipient)
    |> put_assoc(:sender, sender)
    |> validate_required([:sender, :recipient, :type, :message_ts, :message_channel])
  end
end
