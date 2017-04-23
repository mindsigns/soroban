use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :soroban, Soroban.Endpoint,
  secret_key_base: "Yr1UMrN1HpQKuXPUP/5rTXsvxSO0KE8ySujvoK1fArwiL9rowOT1XvWWdlawRgDg"

# Configure your database
config :soroban, Soroban.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  database: "soroban_prod",
  pool_size: 20
