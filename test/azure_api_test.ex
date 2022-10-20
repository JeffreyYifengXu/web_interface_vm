defmodule AzureAPI.Test do

  # use AzureBillingDashboard.DataCase
  use AzureBillingDashboardWeb.ConnCase

  alias AzureAPI.AzureCalls
  alias AzureAPI.VirtualMachineController
  alias AzureBillingDashboardWeb.UserSessionController
  alias AzureBillingDashboard.List_VMs


  describe "azure_api" do

    @user %{
      email: "user2@company.com",
      password: "123456789abc",
      password_confirmation: "123456789abc",
      sub_id: "f2b523ec-c203-404c-8b3c-217fa4ce341e",
      tenant_id: "a6a9eda9-1fed-417d-bebb-fb86af8465d2",
      client_secret: "oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ",
      client_id: "4bcba93a-6e11-417f-b4dc-224b008a7385",
      secrete_id: "95963713-b5f6-42d2-b91a-31acc90bbc95",
      object_id: "eff772c6-c116-4cb5-a4bd-088d5b65dd14",
      resource_group: "usyd-12a"
    }

    test "Genserver creates a state with necessary keys", %{conn: conn} do

      # Ensure genserver has started
      {:ok, pid} = VirtualMachineController.start_link(@user)

      # Assert required keys are there at the end of init
      # Get state of :virtualmachinecontroller
      state = :sys.get_state(pid)

      assert {:ok, _value} = Map.fetch(state, "sub_id")
      assert {:ok, _value} = Map.fetch(state, "tenant_id")
      assert {:ok, _value} = Map.fetch(state, "client_id")
      assert {:ok, _value} = Map.fetch(state, "client_secret")
      assert {:ok, _value} = Map.fetch(state, "resource_group")
      assert {:ok, _value} = Map.fetch(state, "token")
    end

    test "Genserver retrieves virtual machines and stores data" do

      {:ok, pid} = VirtualMachineController.start_link(@user)

      azure_vms = VirtualMachineController.get_virtual_machines()

      # Check for correct storage. This requires the name, status and OS-Disk
      assert length(azure_vms) == length(List_VMs.list_virtualmachines)

      for vm <- List_VMs.list_virtualmachines do
        assert vm.name != ""
        assert vm.status != ""
        assert vm.odisk_name != ""
      end
    end

    test "Genserver starts an azure machine" do

      # Start Genserver
      {:ok, pid} = VirtualMachineController.start_link(@user)

      virtual_machine = Enum.at(List_VMs.list_virtualmachines, 0)

      # Start the first virtual machine that appears
      VirtualMachineController.start_virtual_machine(virtual_machine.name)

      Process.sleep(10000)

      assert String.contains?(virtual_machine.status, "running")
    end

    test "Genserver stops an azure machine" do

    end
  end


end
