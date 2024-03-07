defmodule Server do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "world")
  end

  post "/clientes/:client_id/transacoes" do
    params = Map.put(conn.body_params, "client_id", String.to_integer(client_id))

    case Transactions.create(params) do
      {:ok, client} ->
        send_json(client, conn, 200)

      {:error, :limit_overflow} ->
        send_resp(conn, 422, "")

      {:error, :not_found} ->
        send_resp(conn, 404, "")

      {:error, :invalid_params} ->
        send_resp(conn, 400, "")
    end
  end

  get "/clientes/:client_id/extrato" do
    client_id
    |> String.to_integer()
    |> Clients.statement()
    |> case do
      {:ok, statement} ->
        send_json(statement, conn, 200)

      {:error, :not_found} ->
        send_resp(conn, 404, "")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp send_json(resp, conn, status) do
    send_resp(conn, status, Jason.encode!(resp))
  end
end
