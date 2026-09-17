defmodule PortfolioWeb.PageControllerTest do
  use PortfolioWeb.ConnCase

  test "GET / renders developer portfolio", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Rimwell Jethro Mushilingwa"
    assert html_response(conn, 200) =~ "Stanbic Bank"
  end
end
