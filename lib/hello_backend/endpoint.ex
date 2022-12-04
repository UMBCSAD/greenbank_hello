defmodule HelloBackend.Endpoint do
  use Plug.Router
  use Retry
  require IEx
  require Logger

  @template_dir "lib/hello_backend/templates"
  NimbleCSV.define(CommaParser, separator: ",")

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: :hello_backend,
    only: ~w(images favicon.ico)
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    ### use catclients on pfsense to get the VPN username

    catclients_pw = Application.get_env(:hello_backend, :pfsense_catclients_pw)
    vpn_host = Application.get_env(:hello_backend, :vpn_host)

    {output, _} =
      System.shell(
        "echo #{catclients_pw}" <>
          " | nc -w 2 #{vpn_host} 1984" <>
          " | grep ^CLIENT_LIST"
      )

    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    Logger.info("Incoming request from: " <> user_ip)

    row =
      output
      |> CommaParser.parse_string(skip_headers: false)
      |> Enum.find(fn row -> Enum.at(row, 3) |> IO.inspect == user_ip end)

    Logger.info(inspect(row))
    username = Enum.at(row, 9)

    ### use the Ldap genserver to get LDAP data for that username

    ldap_info =
      retry with: exponential_backoff() |> expiry(5_000) do
        Logger.info("Trying LDAP lookup for #{username}...")
        HelloBackend.Ldap.get_user(HelloBackend.Ldap, username)
      after
        result -> result
      else
        error -> error
      end

    full_name = Map.get(ldap_info, "displayName") |> Enum.at(0)

    emails =
      Map.get(ldap_info, "mail")
      |> Enum.filter(fn m -> not String.contains?(m, "@greenbank.lan") end)

    pass_exp = Map.get(ldap_info, "krbPasswordExpiration") |> Enum.at(0)
    exp_y = String.slice(pass_exp, 0..3) |> String.to_integer()
    exp_m = String.slice(pass_exp, 4..5) |> String.to_integer()
    exp_d = String.slice(pass_exp, 6..7) |> String.to_integer()
    {:ok, pass_exp} = NaiveDateTime.new(exp_y, exp_m, exp_d, 0, 0, 0)

    is_pass_good =
      NaiveDateTime.compare(
        NaiveDateTime.utc_now() |> NaiveDateTime.add(3 * 24 * 60 * 60, :second),
        pass_exp
      ) ==
        :lt

    member_of =
      Map.get(ldap_info, "memberOf")
      |> Enum.map(fn grp -> Regex.run(~r/^cn=([^,]+),/, grp) |> Enum.at(1) end)

    Logger.info(inspect(full_name))
    Logger.info(inspect(emails))
    Logger.info("Password is good: " <> inspect(is_pass_good))
    Logger.info(inspect(member_of))

    ### and reply back with the rendered page

    conn = Plug.Conn.put_resp_header(conn, "Access-Control-Allow-Origin", "*")

    render(conn, "index.html",
      full_name: full_name,
      username: username,
      emails: emails,
      pass_good?: true,
      member_of: member_of,
      vpn_ip: Enum.at(row, 3),
      remote_ip: Enum.at(row, 2)
    )
  end

  get "/ping" do
    conn = Plug.Conn.put_resp_header(conn, "Access-Control-Allow-Origin", "*")
    send_resp(conn, 200, "pong!")
  end

  match _ do
    send_resp(conn, 404, "404 nothin here chief")
  end

  defp render(%{status: status} = conn, template, assigns) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end
end
