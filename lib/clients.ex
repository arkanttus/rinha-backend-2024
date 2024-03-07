defmodule Clients do
  import Ecto.Query

  alias Clients.Client
  alias Transactions.Transaction

  @type client_statement :: %{saldo: map(), ultimas_transacoes: list(map())}

  def update_balance(client_id, operation_type, amount) do
    parsed_amount = parse_amount(amount, operation_type)

    Client
    |> where([c], c.id == ^client_id)
    |> update(inc: [balance: ^parsed_amount])
    |> select([c], %{limite: c.limit, saldo: c.balance})
    |> Repo.update_all([])
    |> case do
      {1, [client]} -> {:ok, client}
      {0, _} -> {:error, :not_found}
    end
  rescue
    Postgrex.Error -> {:error, :limit_overflow}
  end

  defp parse_amount(amount, :c), do: amount
  defp parse_amount(amount, :d), do: -amount

  @spec statement(integer()) :: client_statement()
  def statement(client_id) do
    Client
    |> join(
      :left,
      [c],
      t in subquery(
        Transaction
        |> where([t], t.client_id == ^client_id)
        |> select([t], %{t | rn: fragment("ROW_NUMBER() OVER (ORDER BY created_at DESC)")})
      ),
      on: t.client_id == ^client_id
    )
    |> where([c, t], c.id == ^client_id and (t.rn <= 10 or is_nil(t.rn)))
    |> select([c, t], %{client: c, transaction: t})
    |> Repo.all()
    |> render()
  end

  defp render([]), do: {:error, :not_found}

  defp render([%{client: client, transaction: nil} | _]) do
    {:ok,
     %{
       saldo: %{
         total: client.balance,
         limite: client.limit,
         data_extrato: NaiveDateTime.utc_now()
       },
       ultimas_transacoes: []
     }}
  end

  defp render([%{client: client} | _] = result) do
    {:ok,
     result
     |> Enum.reduce(%{ultimas_transacoes: []}, fn %{transaction: transaction}, acc ->
       transaction_up = %{
         valor: transaction.amount,
         tipo: transaction.operation,
         descricao: transaction.description,
         realizada_em: transaction.created_at
       }

       acc
       |> Map.put(:ultimas_transacoes, acc.ultimas_transacoes ++ [transaction_up])
     end)
     |> Map.put(:saldo, %{
       total: client.balance,
       limite: client.limit,
       data_extrato: NaiveDateTime.utc_now()
     })}
  end
end
