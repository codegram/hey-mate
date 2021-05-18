defmodule HeyMate.Repo do
  use Ecto.Repo,
    otp_app: :hey_mate,
    adapter: Ecto.Adapters.Postgres
end
