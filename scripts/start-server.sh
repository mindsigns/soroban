mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
MIX_ENV=dev iex -S mix phoenix.server
