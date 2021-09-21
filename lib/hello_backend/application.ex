defmodule HelloBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: HelloBackend.Worker.start_link(arg)
      # {HelloBackend.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HelloBackend.Endpoint,
        options: [port: 4001]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
