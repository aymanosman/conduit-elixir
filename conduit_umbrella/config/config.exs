# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

config :conduit, :postgres, database: if(Mix.env() == :test, do: "conduit_test", else: "conduit")

if Mix.env() == :test do
  config :conduit, :postgres, pool: DBConnection.Ownership
end

config :joken,
  default_signer: "QWG58pOlKCxGK9ORfyJ0eysR74Oo3tTE"

{port, ""} =
  Integer.parse(System.get_env("PORT") || if(Mix.env() == :test, do: "4001", else: "4000"))

config :conduit_web, ConduitWeb.Router, port: port
