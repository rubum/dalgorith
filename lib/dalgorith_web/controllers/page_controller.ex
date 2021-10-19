defmodule DalgorithWeb.PageController do
  use DalgorithWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
