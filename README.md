# Soroban
This is my first go with the Phoenix framework.

Soroban is a basic invoicing system for small courier companies.  Born out of my
frustration of inefficient invoicing systems.

Very much a work in progress.  Beware.

## Getting Started

### Prerequisites

You will need Elixir and Postgres installed.

PDF generation requires wkhtmltopdf and xvfb-run.


### Installation

To start your Phoenix app in Dev mode:

```
  ./build.sh
  iex -S mix phoenix.server
```

Populate the database with test data:

```
Forge.gen_all(num_of_clients, num_of_jobs)
```

An good starting point is :

```
Forge.gen_all(15, 500) , which gives you 15 clients and 500 jobs.
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Links to know

http://localhost:4000/sent_emails to see emails in dev mode.


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## License
See [LICENSE](LICENSE).
