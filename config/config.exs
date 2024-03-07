import Config

config :rinha_backend, Repo,
  database: "rinha",
  username: "rinha",
  password: "rinha",
  hostname: "localhost",
  queue_target: 1_000,
  queue_interval: 5_000

config :rinha_backend, ecto_repos: [Repo]

import_config "#{config_env()}.exs"
