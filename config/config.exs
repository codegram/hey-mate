# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hey_mate,
  ecto_repos: [HeyMate.Repo]

config :hey_mate, HeyMate.Rewards.Rewarder, enabled: true

# Configures the endpoint
config :hey_mate, HeyMateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IFK6v+zKWly9ksmFpU3x0yEFgbyDBNmu7qzspn5eEjusWguG3q11Lg/aIilOKXxq",
  render_errors: [view: HeyMateWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HeyMate.PubSub,
  live_view: [signing_salt: "Ln1vMqUJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure POW for user authentication
config :hey_mate, :pow,
  user: HeyMate.Auth.User,
  repo: HeyMate.Repo,
  web_module: HeyMateWeb

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
