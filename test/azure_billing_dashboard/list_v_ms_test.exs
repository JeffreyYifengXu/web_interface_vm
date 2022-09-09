defmodule AzureBillingDashboard.List_VMsTest do
  use AzureBillingDashboard.DataCase

  alias AzureBillingDashboard.List_VMs

  alias Poison.Parser

  describe "virtualmachines" do
    alias AzureBillingDashboard.List_VMs.VirtualMachine

    import AzureBillingDashboard.List_VMsFixtures

    @invalid_attrs %{cost_accrued: nil, cost_so_far: nil, name: nil, process: nil, status: nil}

    test "list_virtualmachines/0 returns all virtualmachines" do
      virtual_machine = virtual_machine_fixture()
      assert List_VMs.list_virtualmachines() == [virtual_machine]
    end

    test "get_virtual_machine!/1 returns the virtual_machine with given id" do
      virtual_machine = virtual_machine_fixture()
      assert List_VMs.get_virtual_machine!(virtual_machine.id) == virtual_machine
    end

    test "create_virtual_machine/1 with valid data creates a virtual_machine" do
      valid_attrs = %{cost_accrued: "some cost_accrued", cost_so_far: "some cost_so_far", name: "some name", process: "some process", status: "some status"}

      assert {:ok, %VirtualMachine{} = virtual_machine} = List_VMs.create_virtual_machine(valid_attrs)
      assert virtual_machine.cost_accrued == "some cost_accrued"
      assert virtual_machine.cost_so_far == "some cost_so_far"
      assert virtual_machine.name == "some name"
      assert virtual_machine.process == "some process"
      assert virtual_machine.status == "some status"
    end

    test "create_virtual_machine/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List_VMs.create_virtual_machine(@invalid_attrs)
    end

    test "update_virtual_machine/2 with valid data updates the virtual_machine" do
      virtual_machine = virtual_machine_fixture()
      update_attrs = %{cost_accrued: "some updated cost_accrued", cost_so_far: "some updated cost_so_far", name: "some updated name", process: "some updated process", status: "some updated status"}

      assert {:ok, %VirtualMachine{} = virtual_machine} = List_VMs.update_virtual_machine(virtual_machine, update_attrs)
      assert virtual_machine.cost_accrued == "some updated cost_accrued"
      assert virtual_machine.cost_so_far == "some updated cost_so_far"
      assert virtual_machine.name == "some updated name"
      assert virtual_machine.process == "some updated process"
      assert virtual_machine.status == "some updated status"
    end

    test "update_virtual_machine/2 with invalid data returns error changeset" do
      virtual_machine = virtual_machine_fixture()
      assert {:error, %Ecto.Changeset{}} = List_VMs.update_virtual_machine(virtual_machine, @invalid_attrs)
      assert virtual_machine == List_VMs.get_virtual_machine!(virtual_machine.id)
    end

    test "delete_virtual_machine/1 deletes the virtual_machine" do
      virtual_machine = virtual_machine_fixture()
      assert {:ok, %VirtualMachine{}} = List_VMs.delete_virtual_machine(virtual_machine)
      assert_raise Ecto.NoResultsError, fn -> List_VMs.get_virtual_machine!(virtual_machine.id) end
    end

    test "change_virtual_machine/1 returns a virtual_machine changeset" do
      virtual_machine = virtual_machine_fixture()
      assert %Ecto.Changeset{} = List_VMs.change_virtual_machine(virtual_machine)
    end

    test "List VM API" do
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

      # IO.inspect(body["statuses"])
      [provision, power] = Enum.map(body["statuses"], fn (x) -> x["code"] end)

      IO.inspect(power)
    end

    # response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/Test-VM-1/instanceView?api-version=2022-03-01", header, []

    # {status, body} = Poison.decode(response.body)

    # # IO.inspect(body["statuses"])
    # [provision, power] = Enum.map(body["statuses"], fn (x) -> x["code"] end)

    # IO.inspect(power)


    end
  end
end
