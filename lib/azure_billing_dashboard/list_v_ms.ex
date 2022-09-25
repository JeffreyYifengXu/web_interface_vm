defmodule AzureBillingDashboard.List_VMs do
  @moduledoc """
  The List_VMs context.
  """
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query, warn: false
  alias AzureBillingDashboard.Repo

  alias AzureBillingDashboard.List_VMs.VirtualMachine
  alias AzureBillingDashboard.List_VMs
  alias AzureAPI.VirtualMachineController

  @doc """
  Returns the list of virtualmachines.

  1. Calls Azure API for authentication
  2. Calls Azure API for listing virtual machines
  3. Cross-checks database and creates new rows if a VM is not present
  4. Returns a list of virtual machines.

  ## Examples

      iex> list_virtualmachines()
      [%VirtualMachine{}, ...]

  """
  def list_virtualmachines do

    VirtualMachineController.get_virtual_machines()

    # # Cross check database
    # for item <- names_and_statuses do
    #   {name, power} = item

    #   if Repo.exists?(from vm in VirtualMachine, where: vm.name == ^name) do
    #     # Get Machine
    #     virtual_machine = Repo.get_by(VirtualMachine, [name: name])
    #     |> update_virtual_machine(%{status: power})
    #   else
    #     # Create Virtual Machine
    #     create_virtual_machine(%{name: name, status: power})
    #   end
    # end

    Repo.all(from p in VirtualMachine, order_by: [desc: p.status])
  end

  @doc """
  Gets a single virtual_machine.

  Raises `Ecto.NoResultsError` if the Virtual machine does not exist.

  ## Examples

      iex> get_virtual_machine!(123)
      %VirtualMachine{}

      iex> get_virtual_machine!(456)
      ** (Ecto.NoResultsError)

  """
  def get_virtual_machine!(id), do: Repo.get!(VirtualMachine, id)

  @doc """
  Creates a virtual_machine.

  ## Examples

      iex> create_virtual_machine(%{field: value})
      {:ok, %VirtualMachine{}}

      iex> create_virtual_machine(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_virtual_machine(attrs \\ %{}) do
    %VirtualMachine{}
    |> VirtualMachine.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a virtual_machine.

  ## Examples

      iex> update_virtual_machine(virtual_machine, %{field: new_value})
      {:ok, %VirtualMachine{}}

      iex> update_virtual_machine(virtual_machine, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_virtual_machine(%VirtualMachine{} = virtual_machine, attrs) do
    virtual_machine
    |> VirtualMachine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a virtual_machine.

  ## Examples

      iex> delete_virtual_machine(virtual_machine)
      {:ok, %VirtualMachine{}}

      iex> delete_virtual_machine(virtual_machine)
      {:error, %Ecto.Changeset{}}

  """
  def delete_virtual_machine(%VirtualMachine{} = virtual_machine) do
    Repo.delete(virtual_machine)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking virtual_machine changes.

  ## Examples

      iex> change_virtual_machine(virtual_machine)
      %Ecto.Changeset{data: %VirtualMachine{}}

  """
  def change_virtual_machine(%VirtualMachine{} = virtual_machine, attrs \\ %{}) do
    VirtualMachine.changeset(virtual_machine, attrs)
  end


  @doc """
  Starts a virtual machine

  """
  def start_virtual_machine(%VirtualMachine{} = virtual_machine) do
    update_virtual_machine(virtual_machine, %{status: "VM running"})
    VirtualMachineController.start_virtual_machine(virtual_machine.name)
  end

   @doc """
  Stops a virtual machine

  """
  def stop_virtual_machine(%VirtualMachine{} = virtual_machine) do
    update_virtual_machine(virtual_machine, %{status: "VM stopped"})
    VirtualMachineController.stop_virtual_machine(virtual_machine.name)
  end
end
