import Config

System.put_env("HTTP_SERVER_PORT", "3000")
System.put_env("DB_HOSTNAME", "db")
System.put_env("DB_POOL_SIZE", "60")

config :logger, level: :info
