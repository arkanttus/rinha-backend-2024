defmodule Transactions do
  alias Transactions.Transaction

  @type client_info :: %{limite: integer(), saldo: integer()}

  @spec create(map()) :: client_info() | {:error, :limit_overflow | :invalid_params | :not_found}
  def create(%{"client_id" => client_id} = params) when client_id in 1..5 do
    case Transaction.build(params) do
      {:ok, %Transaction{operation: op} = transaction_params} -> do_create(op, transaction_params)
      {:error, %Ecto.Changeset{}} -> {:error, :invalid_params}
    end
  end

  def create(_params), do: {:error, :not_found}

  defp do_create(operation_type, transaction_params) do
    query = make_query(operation_type)

    query
    |> Repo.query([
      transaction_params.client_id,
      transaction_params.amount,
      transaction_params.description
    ])
    |> case do
      {:ok, %{rows: rows}} ->
        rows
        |> List.flatten()
        |> parse_result()

      {:error, _} ->
        {:error, :not_found}
    end
  end

  defp make_query(:c),
    do: """
    SELECT * FROM credit($1, $2, $3);
    """

  defp make_query(:d),
    do: """
    SELECT * FROM debit($1, $2, $3);
    """

  defp parse_result(result) do
    case result do
      [_, false, _] -> {:error, :limit_overflow}
      [new_balance, true, limit] -> {:ok, %{limite: limit, saldo: new_balance}}
    end
  end
end
