defmodule Transactions do
  alias Transactions.Transaction

  @type client_info :: %{limite: integer(), saldo: integer()}

  @spec create(map()) :: client_info() | {:error, :limit_overflow | :invalid_params | :not_found}
  def create(params) do
    case Transaction.build(params) do
      {:ok, %Transaction{} = transaction_params} -> do_create(transaction_params)
      {:error, %Ecto.Changeset{}} -> {:error, :invalid_params}
    end
  end

  defp do_create(transaction_params) do
    Repo.transaction(fn ->
      with {:ok, client} <-
             Clients.update_balance(
               transaction_params.client_id,
               transaction_params.operation,
               transaction_params.amount
             ),
           {:ok, _transaction} <- Repo.insert(transaction_params) do
        client
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end
end
