use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

db_config =
  case System.get_env("DATABASE_URL") do
    nil ->
      [
        username: "postgres",
        password: "postgres",
        hostname: "localhost",
        database: "heymate_test#{System.get_env("MIX_TEST_PARTITION")}"
      ]

    db ->
      [url: "#{db}_test#{System.get_env("MIX_TEST_PARTITION")}"]
  end

config :hey_mate,
       HeyMate.Repo,
       db_config ++
         [
           database: "heymate_test#{System.get_env("MIX_TEST_PARTITION")}",
           pool: Ecto.Adapters.SQL.Sandbox
         ]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hey_mate,
  slack_service: HeyMate.Test.Stub.Slack

config :hey_mate, HeyMate.Rewards.Rewarder, enabled: false

# Print only warnings and errors during test
config :logger, level: :warn
