# Soroban

Set up the Postgres Database
    * Install Postgresql server and client
    * Create the dev and production databases
        - sudo su - postgres
        - createdb soroban_dev
        - createdb soroban_prod
    * You need to do this on the local Postgres server and seperately on the
        Docker Postgres server if you want to play around with the Docerized
        version.  The Postgres port is a straight mapping to the Docker container,
        so you'll need to shut down the local DB server first.

    * Edit config/dev.exs to set the postgres user password.

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Try [`localhost:4000/users`](http://localhost:4000/users) to play with a basic CRUD page.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

BURP

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
