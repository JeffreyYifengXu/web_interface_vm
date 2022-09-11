defmodule AzureBillingDashboard.List_VMs do
  @moduledoc """
  The List_VMs context.
  """

  import Ecto.Query, warn: false
  alias AzureBillingDashboard.Repo

  alias AzureBillingDashboard.List_VMs.VirtualMachine
  alias AzureBillingDashboard.List_VMs

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
    HTTPoison.start

    # Get Authorization
    response = HTTPoison.post! "https://login.microsoftonline.com/{tenant_id}/oauth2/token", "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]

    {_status, body} = Poison.decode(response.body)

    token = body["access_token"]

    header = ['Authorization': "Bearer " <> token]

    # List VMs

    response = HTTPoison.get! "https://management.azure.com/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01", header, []
    body = Poison.Parser.parse!(response.body)
    names = Enum.map(body["value"], fn (x) -> x["name"] end)

    IO.inspect(names)
    # IO.inspect(body)

    # Cross-check database
    for name <- names do
      # IO.inspect(name)
      response = HTTPoison.get! "https://management.azure.com/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.Compute/virtualMachines/#{name}/instanceView?api-version=2022-03-01", header, []
      {_status, body} = Poison.decode(response.body)

      # IO.inspect(response)
      [_provision, power] = Enum.map(body["statuses"], fn (x) -> x["displayStatus"] end)

      # IO.inspect(power)

      if Repo.exists?(from vm in VirtualMachine, where: vm.name == ^"#{name}") == false do
        IO.inspect("Creating VM " <> "#{name}")
        List_VMs.create_virtual_machine(%{:name => "#{name}", :status => "#{power}"})
      else
        IO.inspect("Virtual Machine " <> "#{name}" <> " already exists")
        # vm = get_virtual_machine!()
      end
    end

    # IO.inspect(Repo.all(from p in VirtualMachine, order_by: [asc: p.status]))
    Repo.all(from p in VirtualMachine, order_by: [asc: p.status])
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
    Ecto.Changeset.change(virtual_machine, %{status: "VM running"}) |> Repo.update!
  end

   @doc """
  Stops a virtual machine

  """
  def stop_virtual_machine(%VirtualMachine{} = virtual_machine) do
    # changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
    Ecto.Changeset.change(virtual_machine, %{status: "VM deallocated"}) |> Repo.update!
  end
end
