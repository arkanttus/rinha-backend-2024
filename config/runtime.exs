import Config

if config_env() == :prod do
  config :rinha_backend, RinhaBackend.Repo,
    database: System.fetch_env!("DB_NAME"),
    username: System.fetch_env!("DB_USERNAME"),
    password: System.fetch_env!("DB_PASS"),
    hostname: System.fetch_env!("DB_HOSTNAME"),
    port: System.fetch_env!("DB_PORT"),
    pool_size: System.fetch_env!("DB_POOL_SIZE") |> String.to_integer()

  ############
  # Telemetry
  ############
  config :opentelemetry, :processors,
    otel_batch_processor: %{
      exporter: {
        :opentelemetry_exporter,
        %{endpoints: [System.fetch_env!("OTEL_ENDPOINT")]}
      }
    }
end
