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

  ## Examples

      iex> list_virtualmachines()
      [%VirtualMachine{}, ...]

  """
  def list_virtualmachines do
    HTTPoison.start
    # Get Authorization
    # tenantId = a6a9eda9-1fed-417d-bebb-fb86af8465d2

    response = HTTPoison.post! 'https://login.microsoftonline.com/a6a9eda9-1fed-417d-bebb-fb86af8465d2/oauth2/token', "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]

    {status, body} = Poison.decode(response.body)
    # body = Poison.encode!(%{grant_type: "client_credentials", client_id: "4bcba93a-6e11-417f-b4dc-224b008a7385", client_secret: "oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ", resource: "https://management.azure.com/"})

    # "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F"

    # {status, body} = Poison.decode(response.body)

    IO.inspect(body)

    token = body["access_token"]

    IO.inspect(token)

    header = ['Authorization': "Bearer " <> token]

    # List VMs
    """
      See https://docs.microsoft.com/en-us/rest/api/compute/virtual-machines/list?tabs=HTTP
      Header : Authorization: Bearer token
      Get Ids from Bitbucket Wiki
    """

    response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01", header, []
    body = Poison.Parser.parse!(response.body)
    names = Enum.map(body["value"], fn (x) -> x["name"] end)

    names_string = List.to_string(names)
    IO.inspect(names)
    # IO.inspect(body)

    for name <- names do
      IO.inspect(name)
      response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/instanceView?api-version=2022-03-01", header, []
      {status, body} = Poison.decode(response.body)

      IO.inspect(response)
      [provision, power] = Enum.map(body["statuses"], fn (x) -> x["displayStatus"] end)

      IO.inspect(power)

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
    HTTPoison.start
    # Get Authorization
    # tenantId = a6a9eda9-1fed-417d-bebb-fb86af8465d2

    response = HTTPoison.post! 'https://login.microsoftonline.com/a6a9eda9-1fed-417d-bebb-fb86af8465d2/oauth2/token', "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]

    {status, body} = Poison.decode(response.body)
    # body = Poison.encode!(%{grant_type: "client_credentials", client_id: "4bcba93a-6e11-417f-b4dc-224b008a7385", client_secret: "oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ", resource: "https://management.azure.com/"})

    # "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F"

    # {status, body} = Poison.decode(response.body)

    IO.inspect(body)

    token = body["access_token"]

    IO.inspect(token)

    header = ['Authorization': "Bearer " <> token]

    response = HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{virtual_machine.name}/start?api-version=2022-03-01", [], header

    IO.inspect(response)

    # changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
    Ecto.Changeset.change(virtual_machine, %{status: "VM running"}) |> Repo.update!
  end

  def stop_virtual_machine(%VirtualMachine{} = virtual_machine) do
    # changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
    Ecto.Changeset.change(virtual_machine, %{status: "VM deallocated"}) |> Repo.update!
  end

  def stopall_virtual_machine() do
    # changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
    for virtual_machine <- list_virtualmachines() do
      Ecto.Changeset.change(virtual_machine, %{status: "Stopped"}) |> Repo.update!
    end
    # Ecto.Changeset.change(virtual_machine, %{status: "Stopped"}) |> Repo.update!
  end
end
