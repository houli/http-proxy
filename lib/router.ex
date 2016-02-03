defmodule Proxy.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/proxy/:url" do
    {:ok, resp} = HTTPoison.get url

    headers = List.keydelete resp.headers, "Transfer-Encoding", 0

    %{conn | resp_headers: headers}
    |> send_resp(resp.status_code, resp.body)
  end

  match _ do
    conn
    |> send_resp(404, "oops")
  end
end
