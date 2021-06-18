# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :extracker,
  interval: 9_000 # in seconds; 2 hours, 30 minutes

# Configures the endpoint
config :extracker, ExtrackerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+y2RZTJMC25GSHKFchRg9pg37/cr10yGUos1scVPqIBYu3DL07ONCP5giBPxTe0s",
  render_errors: [view: ExtrackerWeb.ErrorView, accepts: ~w(html), layout: false],
  pubsub_server: Extracker.PubSub,
  live_view: [signing_salt: "MAhwdLex"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :format_encoders,
  bencode: ExtrackerWeb.BencodeFormat

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
