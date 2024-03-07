defmodule Transactions.Transaction do
  use Ecto.Schema

  alias Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "transactions" do
    field(:amount, :integer)
    field(:operation, Ecto.Enum, values: [:c, :d])
    field(:description, :string)
    field(:created_at, :naive_datetime_usec)
    field(:client_id, :id)
  end

  def build(params) do
    params = parse(params)

    %__MODULE__{}
    |> Changeset.cast(params, [:amount, :operation, :description, :client_id])
    |> Changeset.validate_required([:amount, :operation, :description, :client_id])
    |> Changeset.validate_number(:amount, greater_than: 0)
    |> Changeset.validate_length(:description, min: 1, max: 10)
    |> Changeset.apply_action(:validate)
  end

  defp parse(params) do
    %{
      client_id: params["client_id"],
      operation: String.to_existing_atom(params["tipo"]),
      description: params["descricao"],
      amount: params["valor"]
    }
  end
end
