defmodule RinhaBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_backend,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env()),
      mod: {RinhaBackend.Application, []}
    ]
  end

  defp extra_applications(:prod),
    do: [:logger, :tls_certificate_check, :opentelemetry_exporter, :opentelemetry]

  defp extra_applications(_),
    do: extra_applications(:prod) ++ [:observer, :wx, :runtime_tools]

  defp aliases do
    [
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.15"},
      {:bandit, "~> 1.2"},
      {:jason, "~> 1.4"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},

      # Telemetry
      {:opentelemetry, "~> 1.3.1"},
      {:opentelemetry_exporter, "~> 1.6.0"},
      {:opentelemetry_ecto, "~> 1.2.0"},
      {:opentelemetry_bandit, "~> 0.1.4"}
    ]
  end
end
