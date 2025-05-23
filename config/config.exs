# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  twitter: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :extensions, %{
  "json" => "application/vnd.api+json"
}

config :mime, :types, %{
  "application/vnd.api+json" => ["json"]
}

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spark, :formatter,
  remove_parens?: true,
  "Ash.Domain": [],
  "Ash.Resource": []

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  twitter: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :twitter, Twitter.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :twitter, TwitterWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TwitterWeb.ErrorHTML, json: TwitterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Twitter.PubSub,
  # Import environment specific config. This must remain at the bottom
  # of this file so it overrides the configuration defined above.
  live_view: [signing_salt: "++AEQwZG"]

config :twitter,
  ecto_repos: [Twitter.Repo],
  ash_domains: [Twitter.Accounts, Twitter.Tweets],
  generators: [timestamp_type: :utc_datetime]

import_config "#{config_env()}.exs"
