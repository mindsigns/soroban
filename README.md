# Soroban
This is my first go with the Phoenix framework.

Soroban is a basic invoicing system for small courier companies.  Born out of my
frustration of inefficient invoicing systems.

Very much a work in progress.  Beware.

Set up the Postgres Database:

    Install Postgresql server and client
    Edit config/dev.exs to set the postgres user password.

To start your Phoenix app in Dev mode:

  * ./build.sh
  * iex -S mix phoenix.server

Or to do it by hand:

     Install dependencies with `mix deps.get`
     Install Node.js dependencies with `npm install`
     Create the priv/static directory `mkdir priv/static`
     Run `mix phoenix.digest` to build assests
     Start Phoenix endpoint with `iex -S mix phoenix.server`

Populate the database with schwifty data:

    After starting soroban via 'iex -S mix phoenix.server', type
    Forge.gen_all(num_of_clients, num_of_jobs)
    An good starting point is :
    Forge.gen_all(15, 500) , which gives you 15 clients and 500 jobs.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Running Soroban in a docker container:
    
     sudo mix compose release prod
     sudo mix compose up

    OR
    
    sudo docker-compose up

Now you can visit [`localhost:8888`](http://localhost:8888) from your browser.

**Links to know :**

http://localhost:4000/sent_emails to see emails in dev mode.


To shut it down:

    * Hit Ctrl-C twice
    * sudo mix compose down


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
