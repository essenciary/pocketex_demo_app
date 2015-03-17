defmodule WebUi.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/", WebUi do
    pipe_through :browser # Use the default browser stack

    get "/", PocketController, :index

    get "pocket/authorize",         PocketController, :authorize
    get "pocket/callback",          PocketController, :callback
    get "pocket/logoff",            PocketController, :logoff
    get "pocket/user_info",         PocketController, :user_info
    get "pocket/items",             PocketController, :items,       as: "pocket_items"
    get "pocket/items/new",         PocketController, :new_item,    as: "new_pocket_item"
    get "pocket/items/:id/update",  PocketController, :update_item, as: "update_pocket_item"
    post "pocket/items/create",     PocketController, :create_item, as: "create_pocket_item"

    get "pocket/items/:id/fav",     PocketController, :fav_item, as: "fav_pocket_item"
    get "pocket/items/:id/unfav",   PocketController, :unfav_item, as: "unfav_pocket_item"
    get "pocket/items/:id/archive", PocketController, :archive_item, as: "archive_pocket_item"
    get "pocket/items/:id/delete",  PocketController, :delete_item, as: "delete_pocket_item"
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebUi do
  #   pipe_through :api
  # end
end
