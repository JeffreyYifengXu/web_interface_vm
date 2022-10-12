defmodule AzureBillingDashboard.List_VMs.VirtualMachine do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  schema "virtualmachines" do
    field :cost_accrued, :string, default: "0.0"
    field :cost_so_far, :string, default: "0.0"
    field :name, :string
    field :process, :string, default: "0.0"
    field :status, :string, default: "VM deallocated"
    field :availability, :string, default: "Available"
    field :max_price, :string, default: "2"
    field :availability_summary, :string, default: "None"
    field :odisk_name, :string

    timestamps()
  end

  @doc false
  def changeset(virtual_machine, attrs) do
    virtual_machine
    |> cast(attrs, [:name, :process, :status, :cost_so_far, :cost_accrued, :availability, :max_price, :availability_summary, :odisk_name])
    |> validate_required([:name])
    # |> Logger.debug "#{name}"
  end
end
