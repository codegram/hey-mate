defmodule HeyMate.Auth.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use PowAssent.Ecto.Schema
  import Ecto.Changeset

  alias HeyMate.Slack
  alias HeyMate.Slack.RewardUser

  schema "users" do
    pow_user_fields()
    field :role, :string, null: false, default: "user"

    belongs_to :reward_user, RewardUser

    timestamps()
  end

  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user admin))
  end

  def user_identity_changeset(
        user_or_changeset,
        %{"token" => %{"user" => %{"id" => slack_id}}} = user_identity,
        attrs,
        user_id_attrs
      ) do
    reward_user = Slack.find_reward_user_or_create_by_slack_id(slack_id)

    user_or_changeset
    |> cast(attrs, [])
    |> put_assoc(:reward_user, reward_user)
    |> pow_assent_user_identity_changeset(user_identity, attrs, user_id_attrs)
  end
end
