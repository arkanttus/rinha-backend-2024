defmodule RinhaBackend.Application do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Repo,
      {Bandit, plug: Server, port: 3000}
    ]

    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
