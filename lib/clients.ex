defmodule Clients do
  import Ecto.Query

  alias Clients.Client
  alias Transactions.Transaction

  @type client_statement :: %{saldo: map(), ultimas_transacoes: list(map())}

  @spec statement(integer()) :: client_statement()
  def statement(client_id) when client_id in 1..5 do
    fn ->
      with %Client{} = client <- Repo.get(Client, client_id),
           transactions <- get_transactions(client_id) do
        render(client, transactions)
      else
        nil -> :not_found
      end
    end
    |> Repo.transaction()
    |> case do
      {:ok, :not_found} -> {:error, :not_found}
      {:ok, statement} -> {:ok, statement}
    end
  end

  def statement(_client_id), do: {:error, :not_found}

  defp get_transactions(client_id) do
    Transaction
    |> where([t], t.client_id == ^client_id)
    |> order_by([t], desc: t.created_at)
    |> limit(10)
    |> Repo.all()
  end

  defp render(client, transactions) do
    up_transactions =
      Enum.map(transactions, fn transaction ->
        %{
          valor: transaction.amount,
          tipo: transaction.operation,
          descricao: transaction.description,
          realizada_em: transaction.created_at
        }
      end)

    %{
      saldo: %{
        total: client.balance,
        limite: client.limit,
        data_extrato: NaiveDateTime.utc_now()
      },
      ultimas_transacoes: up_transactions
    }
  end
end
