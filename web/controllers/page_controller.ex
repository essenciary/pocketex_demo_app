defmodule WebUi.PageController do
  use WebUi.Web, :controller

  plug :action

  def index(conn, _params) do
    pocket_username = get_session(conn, :pocket_username)

    render conn, "index.html", pocket_username: pocket_username
  end

  def pocket(conn, _params) do
    render conn, "index.html"
  end
end
