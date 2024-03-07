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
    do: [:logger]

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
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
