use Mix.Config

config :extracker,
  interval_s: 9_000, # in seconds; 2 hours, 30 minutes
  cleanup_interval_ms: 1_000, # in milliseconds
  host: :_, # Cowboy host value, :_ if none
  path: "/",
  port: 6969
