mix deps.get

if [ ! -d priv/static ]; then
    mkdir priv/static
    mkdir priv/static/pdf
else
    rm -rf priv/static/*
fi

npm install
node node_modules/brunch/bin/brunch build
mix phoenix.digest
mix run priv/repo/seeds.exs
