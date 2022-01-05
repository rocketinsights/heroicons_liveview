defmodule HeroiconsLiveView.MixProject do
  use Mix.Project

  @project_url "https://github.com/rocketinsights/heroicons_liveview"
  @version "0.5.0"

  def project do
    [
      app: :heroicons_liveview,
      version: @version,
      elixir: "~> 1.10",
      description: "A collection of Phoenix LiveView Components for all SVG Heroicons",
      organization: "Rocket Insights",
      source_url: @project_url,
      homepage_url: @project_url,
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.2.2", only: :dev},
      {:floki, "~> 0.32.0", only: :dev, runtime: false},
      {:phoenix_live_view, ">= 0.16.0"}
    ]
  end

  defp package() do
    [
      maintainers: ["Jon Principe"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @project_url,
        "Rocket Insights" => "https://rocketinsights.com",
        "Jon Principe" => "https://github.com/jprincipe"
      }
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "deps.compile", "compile"]
    ]
  end
end
