import Config

config :rinha_backend, RinhaBackend.Repo,
  database: "rinha",
  username: "rinha",
  password: "rinha",
  hostname: "localhost",
  port: 5432

System.put_env("HTTP_SERVER_PORT", "3000")
System.put_env("DB_POOL_SIZE", "60")
