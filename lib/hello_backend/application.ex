defmodule HelloBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    p = Application.get_env(:hello_backend, :port)

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: HelloBackend.Endpoint,
        options: [port: p]
      ),
      {HelloBackend.Ldap, name: HelloBackend.Ldap}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloBackend.Supervisor]
    Logger.info("Starting application...")
    Logger.info("############################")
    Logger.info("    STARTING ON PORT #{p} ")
    Logger.info("############################")

    Supervisor.start_link(children, opts)
  end
end
