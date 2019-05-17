use Mix.Config

config :demo, DemoWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "161.117.83.227", port: 80]

# Do not print debug messages in production
config :logger, level: :warn

# Configure your database
config :backend, Backend.Repo,
  pool_size: 10

  api_key =
  System.get_env("SEND_GRID_API_KEY") || "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"

config :backend, Backend.EmailService.SendGrid,
  adapter: Bamboo.SendGridAdapter,
  api_key: api_key