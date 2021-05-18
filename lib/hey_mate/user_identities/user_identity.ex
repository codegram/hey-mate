defmodule HeyMate.UserIdentities.UserIdentity do
  use Ecto.Schema
  use PowAssent.Ecto.UserIdentities.Schema, user: HeyMate.Auth.User

  schema "user_identities" do
    pow_assent_user_identity_fields()

    timestamps()
  end
end
