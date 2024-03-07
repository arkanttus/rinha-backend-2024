import Config

if config_env() == :prod do
  config :rinha_backend, Repo,
    database: System.fetch_env!("DB_NAME"),
    username: System.fetch_env!("DB_USERNAME"),
    password: System.fetch_env!("DB_PASS"),
    hostname: System.fetch_env!("DB_HOSTNAME"),
    port: System.fetch_env!("DB_PORT"),
    pool_size: System.fetch_env!("DB_POOL_SIZE") |> String.to_integer()
end
