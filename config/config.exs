# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :soroban,
  ecto_repos: [Soroban.Repo]

# Configures the endpoint
config :soroban, Soroban.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "aNFSebyymWf897GTjjzETL8OqpsYtPZ/EdsRRi+5Q+hIwIUGanIN/p/1bRC7kUQ+",
  render_errors: [view: Soroban.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Soroban.PubSub,
  adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :generators,
  migration: true,
  binary_id: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :soroban, Soroban.Mailer,
  adapter: Bamboo.LocalAdapter

