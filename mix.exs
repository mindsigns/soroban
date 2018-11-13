defmodule Soroban.Mixfile do
  use Mix.Project

  def project do
    [
      app: :soroban,
      version: "0.0.1",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Soroban, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :bamboo,
        :bamboo_smtp,
        :pdf_generator,
        :drab,
        :timex,
        :faker,
        :blacksmith
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_reload, "~> 1.2.0", only: :dev},
      {:plug_cowboy, "~> 1.0"},
      {:distillery, "~> 1.5", runtime: false},
      {:openmaize, "~> 3.0"},
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.3.0"},
      {:money, "~> 1.3"},
      # {:pdf_generator, ">=0.3.6"},
      {:pdf_generator, git: "https://github.com/gutschilla/elixir-pdf-generator"},
      {:drab, "~> 0.8.3"},
      {:porcelain, "~> 2.0"},
      {:timex, "~> 3.1"},
      {:blacksmith, "~> 0.1"},
      {:faker, "~> 0.8"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
