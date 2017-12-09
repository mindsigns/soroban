# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :soroban,
  ecto_repos: [Soroban.Repo],
  pdf_dir: "./priv/static/pdf/"

# Configures the endpoint
config :soroban, Soroban.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "3iuyxvwp3x1NdoR8__OdtMomlCsJtRl1kgPCnrV_4JsC4Z3O2P2TWt6wi9lBYQKjf8isHCsZMWYv2n7zK7cOIZQ4cMwaXl2cJk+/_",
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

config :phoenix, :template_engines,
  drab: Drab.Live.Engine

#config :soroban, Soroban.Mailer,
#adapter: Bamboo.LocalAdapter

config :soroban, Soroban.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "localhost",
  hostname: "zoomsf.com",
  port: 25,
  #username: "invoice@zoomsf.com", # or {:system, "SMTP_USERNAME"}
  #password: "pa55word", # or {:system, "SMTP_PASSWORD"}
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: false, # can be `true`
  retries: 1

config :money,
  default_currency: :USD

config :pdf_generator,
  wkhtml_path:    "/usr/bin/wkhtmltopdf",
  command_prefix: ["/usr/bin/xvfb-run", "-a"]

import_config "#{Mix.env}.exs"
