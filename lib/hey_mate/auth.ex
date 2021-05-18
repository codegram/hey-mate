defmodule HeyMate.Auth do
  @moduledoc """
  The Auth context.
  """

  alias HeyMate.Repo
  alias HeyMate.Auth.User

  def is_admin?(%{role: "admin"}), do: true
  def is_admin?(_any), do: false

  def set_admin_role(user) do
    user
    |> User.changeset_role(%{role: "admin"})
    |> Repo.update()
  end
end
