import Config

config :rinha_backend, RinhaBackend.Repo,
  database: "rinha",
  username: "rinha",
  password: "rinha",
  hostname: "localhost",
  queue_target: 1_000,
  queue_interval: 5_000

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

############
# Telemetry
############

config :opentelemetry, :resource, service: %{name: "rinha_backend"}

import_config "#{config_env()}.exs"
