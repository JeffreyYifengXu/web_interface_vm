defmodule AzureBillingDashboard.List_VMs do
  @moduledoc """
  The List_VMs context.
  """

  import Ecto.Query, warn: false
  alias AzureBillingDashboard.Repo

  alias AzureBillingDashboard.List_VMs.VirtualMachine

  @doc """
  Returns the list of virtualmachines.

  ## Examples

      iex> list_virtualmachines()
      [%VirtualMachine{}, ...]

  """
  def list_virtualmachines do
    Repo.all(VirtualMachine)
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
    # changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
    Ecto.Changeset.change(virtual_machine, %{status: "Running"}) |> Repo.update!
  end

  def stop_virtual_machine(%VirtualMachine{} = virtual_machine) do
    # changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
    Ecto.Changeset.change(virtual_machine, %{status: "Stopped"}) |> Repo.update!
  end
end
