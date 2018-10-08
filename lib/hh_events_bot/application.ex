defmodule HHEventsBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {HHEventsBot.Server, Application.get_env(:hh_events_bot, :token)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HHEventsBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end