defmodule Soroban do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    repo = Soroban.Repo
    create_db(repo)

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Soroban.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Soroban.Endpoint, []),
      # Start your own worker by calling: Soroban.Worker.start_link(arg1, arg2, arg3)
      # worker(Soroban.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Soroban.Supervisor]
    sup_ret = Supervisor.start_link(children, opts)

    run_migrations(repo)
    sup_ret

  end

  def create_db(repo) do
    case repo.__adapter__.storage_up(repo.config) do
      :ok ->
        IO.puts "The database for #{inspect repo} has been created."
      {:error, :already_up} ->
        IO.puts "The database for #{inspect repo} has already been created."
      {:error, term} when is_binary(term) ->
        IO.puts "The database for #{inspect repo} couldn't be created, reason given: #{term}."
      {:error, term} ->
        IO.puts "The database for #{inspect repo} couldn't be created, reason given: #{inspect term}."
    end
  end

  def run_migrations(repo) do
    migrations_path = repo.config()
                |> Keyword.fetch!(:otp_app)
                |> Application.app_dir()
                |> Path.join("priv")
                |> Path.join("repo")
                |> Path.join("migrations")
    IO.puts "migrations path: #{inspect migrations_path}"
    Ecto.Migrator.run(repo, migrations_path, :up, [all: true])
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Soroban.Endpoint.config_change(changed, removed)
    :ok
  end
end
