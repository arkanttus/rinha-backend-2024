defmodule RinhaBackend.Application do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      RinhaBackend.Repo,
      {Bandit, plug: Server, port: 3000}
    ]

    :ok = OpentelemetryEcto.setup([:rinha_backend, :repo])
    :ok = OpentelemetryBandit.setup()
    # System.fetch_env!("HTTP_SERVER_PORT")

    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts) |> IO.inspect()
  end
end
