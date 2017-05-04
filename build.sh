mix deps.get
npm install
mkdir priv/static
node node_modules/brunch/bin/brunch build
mix phoenix.digest
