defmodule HeyMate.Release do
  @app :hey_mate

  def db_create do
    load_app()

    for repo <- repos() do
      :ok =
        case repo.__adapter__.storage_up(repo.config) do
          :ok -> :ok
          {:error, :already_up} -> :ok
          {:error, term} -> {:error, term}
        end
    end
  end

  def db_migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def db_rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
