import Config

config :hello_backend,
  port: 80

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  level: :info

config :paddle, Paddle,
  host: "ipa.greenbank.lan",
  base: "cn=accounts,dc=greenbank,dc=lan",
  ssl: true,
  port: 636,
  account_subdn: "cn=users"

import_config("secret.exs")
