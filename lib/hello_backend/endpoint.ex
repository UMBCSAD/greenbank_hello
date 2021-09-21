defmodule HelloBackend.Endpoint do
  use Plug.router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong!")
  end

  match _ do
    send_resp(conn, 404, "404 nothin here chief")
  end
end
