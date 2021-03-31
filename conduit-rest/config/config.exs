# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :joken,
  default_signer: "QWG58pOlKCxGK9ORfyJ0eysR74Oo3tTE"

config :conduit,
  ecto_repos: [Conduit.Repo]

# Configures the endpoint
config :conduit, ConduitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9QyXbYjYVnu+l2UmIZuUEfjGGOD378ayWxBUpEe8G/34s+tfkraYv0V7eQF0avWs",
  render_errors: [view: ConduitWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Conduit.PubSub,
  live_view: [signing_salt: "gAgpOp8z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
