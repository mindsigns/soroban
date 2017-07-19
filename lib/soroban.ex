defmodule Soroban do
@moduledoc """
Soroban module
"""

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    repo = Soroban.Repo
    create_db(repo)

    children = [
      supervisor(Soroban.Repo, []),
      supervisor(Soroban.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Soroban.Supervisor]
    sup_ret = Supervisor.start_link(children, opts)

    run_migrations(repo)
    sup_ret

  end

  @doc """
  Create the database if it does not already exist on start
  """
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

  @doc """
  Run migrations on start
  """
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

  @doc """
  Tell Phoenix to update the endpoint configuration
  whenever the application is updated.
  """
  def config_change(changed, _new, removed) do
    Soroban.Endpoint.config_change(changed, removed)
    :ok
  end
end
