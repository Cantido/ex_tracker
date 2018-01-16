use Mix.Config

config :extracker,
  interval: 9_000, # in seconds; 2 hours, 30 minutes
  cleanup_interval: 1_000, # in milliseconds
  host: :_, # Cowboy host value, :_ if none
  path: "/",
  port: 6969
