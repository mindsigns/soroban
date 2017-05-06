# Soroban

Set up the Postgres Database:

    Install Postgresql server and client
    Edit config/dev.exs to set the postgres user password.

To start your Phoenix app in Dev mode:

  * run ./build.sh

Or to do it by hand:

     Install dependencies with `mix deps.get`
     Install Node.js dependencies with `npm install`
     Create the priv/static directory `mkdir priv/static`
     Run `mix phoenix.digest` to build assests
     Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Running Soroban in a docker container:
    
     sudo mix compose release prod
     sudo mix compose up

Now you can visit [`localhost:8888`](http://localhost:8888) from your browser.

**Links to know :**

http://localhost:4000/users to play with a basic CRUD page

http://localhost:4000/sent_emails to see emails in dev mode.


To shut it down:

    * Hit Ctrl-C twice
    * sudo mix compose down


Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

BURP

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
