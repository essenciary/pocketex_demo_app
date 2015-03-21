# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :web_ui, WebUi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WohGYFMYvpEqR6083DfUgLejeu9/l/0ks9vqow56WWBBLstUubHtKvFs+HA83QTR",
  debug_errors: false,
  pubsub: [name: WebUi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, MyApp.Router,
  session: [store: :cookie,
            key: "fo4jfos9df0sfasliji4309fujdspa"]

config :pocket,
  consumer_key: "_your_pocket_consumer_key_"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
