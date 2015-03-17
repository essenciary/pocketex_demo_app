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
    conn
    |> put_session(:pocket_request_token, response[:request_token])
    |> redirect(external: Pocketex.Auth.autorization_uri(response[:request_token], (WebUi.Router.Helpers.pocket_path(conn, :callback) |> WebUi.Endpoint.url)))
  end

  def callback(conn, _params) do
    case Pocketex.Auth.authorize(@consumer_key, get_session(conn, :pocket_request_token)) do
      {:ok, response} ->
        conn
        |> put_session(:pocket_username, response["username"])
        |> put_session(:pocket_access_token, response["access_token"])
        |> put_flash(:notice, "You have successfully logged into Pocket")
        |> redirect to: WebUi.Router.Helpers.pocket_path(conn, :index)
      true ->
        conn
        |> put_flash(:error, "Authentication to Pocket failed")
        |> redirect to: WebUi.Router.Helpers.pocket_path(conn, :index)
    end
  end

  def items(conn, _params) do
    response = Pocketex.Item.get(@consumer_key, get_session(conn, :pocket_access_token),
                                %{count: 10, detail_type: "complete", sort: "newest",
                                state: "unread", content_type: "all"})

    case response do
      {:ok, items} ->
        render conn, "items.html", items: items["list"]
      {:ko, _} ->
        json conn, %{ko: "En error occured while trying to get the Pocket items"}
    end
  end

  def new_item(conn, _params) do
    render conn, "new.html"
  end

  def create_item(conn, params) do
    case Pocketex.Item.create(@consumer_key, get_session(conn, :pocket_access_token), params["pocket_item"]) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Item was added to your pocket")
        |> redirect to: WebUi.Router.Helpers.pocket_items_path(conn, :items)
      {:ko, error} ->
        conn
        |> put_flash(:error, "Adding item failed")
        |> render WebUi.Router.Helpers.new_pocket_item_path(conn, :index), pocket_item: params["pocket_item"], error: error
    end
  end

  def fav_item(conn, params) do
    case Pocketex.Item.fav(@consumer_key, get_session(conn, :pocket_access_token), params["id"]) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Item was favorited")
        |> redirect to: WebUi.Router.Helpers.pocket_items_path(conn, :items)
      {:ko, error} ->
        conn
        |> put_flash(:error, "Adding item to favorites failed")
        |> render WebUi.Router.Helpers.pocket_items_path(conn, :items), error: error
    end
  end

  def unfav_item(conn, params) do
    case Pocketex.Item.unfav(@consumer_key, get_session(conn, :pocket_access_token), params["id"]) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Item was removed from favorites")
        |> redirect to: WebUi.Router.Helpers.pocket_items_path(conn, :items)
      {:ko, error} ->
        conn
        |> put_flash(:error, "Removing item from favorites failed")
        |> render WebUi.Router.Helpers.pocket_items_path(conn, :items), error: error
    end
  end

  def archive_item(conn, params) do
    case Pocketex.Item.archive(@consumer_key, get_session(conn, :pocket_access_token), params["id"]) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Item was archived")
        |> redirect to: WebUi.Router.Helpers.pocket_items_path(conn, :items)
      {:ko, error} ->
        conn
        |> put_flash(:error, "Archiving item has failed")
        |> render WebUi.Router.Helpers.pocket_items_path(conn, :items), error: error
    end
  end

  def delete_item(conn, params) do
    case Pocketex.Item.delete(@consumer_key, get_session(conn, :pocket_access_token), params["id"]) do
      {:ok, _} ->
        conn
        |> put_flash(:notice, "Item was deleted")
        |> redirect to: WebUi.Router.Helpers.pocket_items_path(conn, :items)
      {:ko, error} ->
        conn
        |> put_flash(:error, "Deleting item has failed")
        |> render WebUi.Router.Helpers.pocket_items_path(conn, :items), error: error
    end
  end

  def logoff(conn, _params) do
    conn
    |> delete_session(:pocket_username)
    |> delete_session(:pocket_access_token)
    |> redirect to: WebUi.Router.Helpers.pocket_path(conn, :index)
  end

  def user_info(conn, _params) do
    json conn, %{ consumer_key: @consumer_key,
                  access_token: get_session(conn, :pocket_access_token),
                  pocket_username: get_session(conn, :pocket_username)}
  end
end
