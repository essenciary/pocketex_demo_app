defmodule WebUi.PocketController do
  use WebUi.Web, :controller

  plug :action

  @consumer_key               Application.get_env(:pocket, :consumer_key)
  @redirect_uri               Application.get_env(:pocket, :redirect_uri)

  def index(conn, _params) do
    pocket_username = get_session(conn, :pocket_username)

    render conn, "index.html", pocket_username: pocket_username
  end

  def authorize(conn, _params) do
    {:ok, response} = Pocketex.Auth.get_request_token(@consumer_key, @redirect_uri)
    request_token = response[:request_token]
    conn = put_session(conn, :pocket_request_token, request_token)

    redirect conn, external: Pocketex.Auth.autorization_uri(request_token, (WebUi.Router.Helpers.pocket_path(conn, :callback) |> WebUi.Endpoint.url))
  end

  def callback(conn, _params) do
    {status, response} = Pocketex.Auth.authorize(@consumer_key, get_session(conn, :pocket_request_token))
    if ( status == :ok ) do
      conn = put_session(conn, :pocket_username, response["username"])
      conn = put_session(conn, :pocket_access_token, response["access_token"])

      conn
      |> put_flash(:notice, "You have successfully logged into Pocket")
      # |> render "index.html", pocket_username: response["username"]
      |> redirect to: WebUi.Router.Helpers.pocket_path(conn, :index)
    else
      conn
      |> put_flash(:error, "Authentication to Pocket failed")
      |> redirect to: WebUi.Router.Helpers.pocket_path(conn, :index)
    end
  end

  def items(conn, _params) do
    {status, items} = Pocketex.Item.get(@consumer_key, get_session(conn, :pocket_access_token),
                                    %{count: 10, detail_type: "simple", sort: "newest", state: "unread", content_type: "article"})
    if ( status == :ok && !Enum.empty?(items["list"]) ) do
      # json conn, items["list"]
      render conn, "items.html", items: items["list"]
    else
      json conn, %{ko: "En error occured while trying to get the Pocket items"}
    end
  end

  def new_item(conn, _params) do
    render conn, "new.html"
  end

  def create_item(conn, _params) do
    #+TODO: add code to create item
  end

  def logoff(conn, _params) do
    conn
    |> delete_session(:pocket_username)
    |> delete_session(:pocket_access_token)
    |> redirect to: WebUi.Router.Helpers.page_path(conn, :index)
  end

  def user_info(conn, _params) do
    json conn, %{ consumer_key: @consumer_key,
                  access_token: get_session(conn, :pocket_access_token),
                  pocket_username: get_session(conn, :pocket_username)}
  end
end
