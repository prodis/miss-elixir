defmodule Miss.MixProject do
  use Mix.Project

  @app :miss
  @name "Miss Elixir"
  @repo "https://github.com/prodis/miss-elixir"
  @version "0.1.5"

  def project do
    [
      app: @app,
      name: @name,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      description: description(),
      docs: docs(),
      package: package(),
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application, do: []

  defp deps do
    [
      # Development
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},

      # Test
      {:decimal, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp description do
    """
    Some functions that I miss in Elixir standard library (and maybe you too).

    Miss Elixir brings in a non-intrusive way some extra functions that, for different reasons,
    are not part of the Elixir standard library.
    """
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ~w(README.md CHANGELOG.md),
      formatters: ~w(html),
      logo: "assets/miss-elixir-logo.png",
      source_ref: @version,
      source_url: @repo,
      canonical: "http://hexdocs.pm/miss"
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE),
      maintainers: ["Fernando Hamasaki de Amorim"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @repo}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.travis": :test
    ]
  end
end
