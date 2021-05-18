defmodule HeyMate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HeyMate.Repo,
      # Start the Telemetry supervisor
      HeyMateWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HeyMate.PubSub},
      # Start the Endpoint (http/https)
      HeyMateWeb.Endpoint
      # Start a worker by calling: HeyMate.Worker.start_link(arg)
    ]

    children =
      if Application.get_env(:hey_mate, HeyMate.Rewards.Rewarder)[:enabled],
        do: children ++ [HeyMate.Rewards.Rewarder],
        else: children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HeyMate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HeyMateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
