mix deps.get
#mix ecto.drop
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
MIX_ENV=dev mix phoenix.server
