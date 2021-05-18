defmodule HeyMateWeb.Admin.SettingsController do
  use HeyMateWeb, :controller

  alias HeyMate.Admin
  alias HeyMate.Admin.Settings

  def index(conn, _params) do
    render(conn, "index.html", settings: current_settings())
  end

  def update(conn, %{"settings" => settings} = _params) do
    case Admin.update_settings(settings) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Settings updated successfully!")
        |> redirect(to: Routes.settings_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Oops! Something went wrong!")
        |> redirect(to: Routes.settings_path(conn, :index))
    end
  end

  defp current_settings do
    Admin.get_current_settings() |> Settings.changeset()
  end
end
