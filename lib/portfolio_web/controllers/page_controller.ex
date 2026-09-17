defmodule PortfolioWeb.PageController do
  use PortfolioWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
