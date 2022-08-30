defmodule AzureBillingDashboard.List_VMs.VirtualMachine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "virtualmachines" do
    field :cost_accrued, :string
    field :cost_so_far, :string
    field :name, :string
    field :process, :string
    field :status, :string
    # field :status_bool, :boolean

    timestamps()
  end

  @doc false
  def changeset(virtual_machine, attrs) do
    virtual_machine
    |> cast(attrs, [:name, :process, :status, :cost_so_far, :cost_accrued])
    |> validate_required([:name, :process, :status, :cost_so_far, :cost_accrued])
  end

  def start_machine(virtual_machine) do
    virtual_machine
    |> cast("Running", [:status])
  end
end
