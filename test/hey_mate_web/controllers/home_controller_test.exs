defmodule HeyMateWeb.HomeControllerTest do
  use HeyMateWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "HeyMate!"
  end
end
