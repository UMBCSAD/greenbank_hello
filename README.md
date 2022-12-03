# SAD Greenbank: Hello Page

A small landing/welcome page for Greenbank users.

Displays username by fetching it from the custom catclients service on pfSense, displays user information by running the username through LDAP. Shows some useful quick links.

Run with `mix run --no-halt`. See setup instructions below.

![image](https://user-images.githubusercontent.com/2071451/134284214-ccce2120-53b8-4f43-aacf-ddbba28c9c61.png)

![image](https://user-images.githubusercontent.com/2071451/134284247-6df725ed-bbec-4ecc-a9d2-207bc1d31ee6.png)

## Setup

Install Elixir by the standard procedure for your distro. On recent Ubuntu (22), `apt install elixir` sufficies.
Also do `apt install erlang-eldap`.

Create a secret file in `config/secret.exs`, as follows:

```elixir
import Config

config :hello_backend,
  pfsense_catclients_pw: "password_to_activate_catclients",
  ldap_user: "viewer",
  ldap_pw: "ldap_users_password_here"
```

Also edit `config/config.exs` as necessary. Probably edit the LDAP host and baseDN for Paddle.

Now do `mix deps.get` to install dependencies. Run the server with `mix run --no-halt`.

### systemd service

**Example setup**. In `/etc/systemd/system/hello.service`:

```ini
[Unit]
Description=greenbank hello welcome/landing page

[Service]
Type=simple
User=root
Group=root
Environment=HOME=/home/root
WorkingDirectory=/root/greenbank_hello
ExecStart=/root/greenbank_hello/_build/dev/rel/hello_backend/bin/hello_backend start
Restart=on-failure
RestartSec=60

[Install]
WantedBy=multi-user.target
```
