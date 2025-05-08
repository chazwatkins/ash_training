import Config

config :ash, :policies, show_policy_breakdowns?: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# In test we don't send emails.
config :twitter, Twitter.Mailer, adapter: Swoosh.Adapters.Test

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :twitter, Twitter.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "twitter_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twitter, TwitterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RV1sFxpS+HKrCfrcf3ga+g7M5BtUrFkuFpn1qES7P0gr3pQ7lABjaAdE2fF+neT/",
  server: false
