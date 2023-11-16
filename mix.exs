defmodule CsvFormat.MixProject do
  use Mix.Project

  def project do
    [
      app: :csv_format,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.1", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.1.1", only: [:dev, :test], runtime: false},
      {:nimble_csv, "~> 1.1"}
    ]
  end
end
