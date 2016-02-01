defmodule Proxy.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Hello World!")
  end

  match _ do
    conn
    |> send_resp(404, "oops")
  end
end
