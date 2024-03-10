import Config

System.put_env("HTTP_SERVER_PORT", "3000")
System.put_env("DB_HOSTNAME", "db")
System.put_env("DB_POOL_SIZE", "60")
System.put_env("OTEL_ENDPOINT", "http://otel-collector:4318")

config :logger, level: :info
