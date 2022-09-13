defmodule AzureBillingDashboardWeb.VirtualMachineLive.Index do
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs
  alias AzureBillingDashboard.List_VMs.VirtualMachine
  alias AzureBillingDashboard.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Virtual machine")
    |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Virtual machine")
    |> assign(:virtual_machine, %VirtualMachine{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Virtual machines")
    |> assign(:virtual_machine, nil)
  end

  @doc """
    Handles event when "Delete" is clicked
  """
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    {:ok, _} = List_VMs.delete_virtual_machine(virtual_machine)

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @doc """
    Handles event when "Start" is clicked
  """
  def handle_event("start", %{"id" => id, "token" => token}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)

    name = virtual_machine.name

    header = ['Authorization': "Bearer " <> token]

    # Get Costs

    response = HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/start?api-version=2022-08-01", [], header


    IO.inspect(response)

    # virtual_machine = List_VMs.get_virtual_machine!(id)
    List_VMs.start_virtual_machine(virtual_machine)

    # {:noreply, assign(socket, :virtual_machine.process, 100)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @doc """
    Handles event when "Stop" is clicked
  """
  def handle_event("stop", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)

    name = virtual_machine.name

    IO.inspect("name = " <> name)

    # IO.inspect("https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/start?api-version=2022-08-01")

    HTTPoison.start
    # Get Authorization
    # tenantId = a6a9eda9-1fed-417d-bebb-fb86af8465d2

    response = HTTPoison.post! "https://login.microsoftonline.com/a6a9eda9-1fed-417d-bebb-fb86af8465d2/oauth2/token", "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]

    {status, body} = Poison.decode(response.body)

    IO.inspect(body)

    token = body["access_token"]

    IO.inspect(token)

    header = ['Authorization': "Bearer " <> token]

    # Get Costs

    response = HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/powerOff?api-version=2022-08-01", [], header
    List_VMs.stop_virtual_machine(virtual_machine)

    # {:noreply, assign(socket, :virtual_machine.process, 100)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @doc """
    Handles event when "Batch Start" is clicked
  """
  def handle_event("batch-start", _param, socket) do
    # {}
    # virtual_machine = List_VMs.get_virtual_machine!(id)
    virtual_machines = List_VMs.list_virtualmachines()
    for machine <- virtual_machines do
      List_VMs.start_virtual_machine(machine)
    end
    # {:noreply, assign(socket, :virtual_machine.process, 0)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @doc """
    Handles event when "Batch Stop" is clicked
  """
  def handle_event("batch-stop", _param, socket) do
    virtual_machines = List_VMs.list_virtualmachines()
    for machine <- virtual_machines do
      List_VMs.stop_virtual_machine(machine)
    end
    # {:noreply, assign(socket, :virtual_machine.process, 0)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  defp list_virtualmachines do
    List_VMs.list_virtualmachines()
  end

  # defp apply_action(socket, :start, _params) do
  #   socket
  #   |> assign(:page_title, "Start VM")
  #   |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))
  # end

end
