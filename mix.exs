defmodule Scrapex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :scrapex,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps do
    [
      {:exq, "~> 0.9.0"},
      {:httpoison, "~> 0.10.0", optional: true},
      {:hound, "~> 1.0" , optional: true},
      {:credo, "~> 0.5", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
    ]
  end
end
