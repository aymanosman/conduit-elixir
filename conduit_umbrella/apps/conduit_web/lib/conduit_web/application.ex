defmodule ConduitWeb.Application do
  use Application

  @impl true
  def start(_type, _args) do
    [{:port, port}] = Application.get_env(:conduit_web, ConduitWeb.Router, :port)

    children = [
      {Plug.Cowboy, scheme: :http, plug: ConduitWeb.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: ConduitWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
