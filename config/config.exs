import Config

config :hello_backend,
  vpn_host: "10.42.0.10",
  port: 80

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  level: :info

config :paddle, Paddle,
  host: "auth.umbcsad.club",
  base: "cn=accounts,dc=umbcsad,dc=club",
  ssl: true,
  port: 636,
  account_subdn: "cn=users"

import_config("secret.exs")
# ## expected in config/secret.exs ##
# config :hello_backend,
#   pfsense_catclients_pw: "PWHERE",
#   ldap_user: "USERNAMEHERE",
#   ldap_pw: "PASSWORDHERE"
