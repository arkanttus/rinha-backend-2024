defmodule Clients.Client do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "clients" do
    field(:limit, :integer)
    field(:balance, :integer)
  end
end
