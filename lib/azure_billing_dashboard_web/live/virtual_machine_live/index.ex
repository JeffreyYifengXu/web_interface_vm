defmodule AzureBillingDashboardWeb.VirtualMachineLive.Index do
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs
  alias AzureBillingDashboard.List_VMs.VirtualMachine
  # alias AzureBillingDashboard.Repo
  alias AzureAPI.VirtualMachineController

  defmodule Start do
    defstruct id: "start", value: nil
  end

  defmodule Stop do
    defstruct id: "stop", value: nil
  end

  @impl true
  def mount(_params, _session, socket) do
    VirtualMachineController.start_link(socket)
    {:ok, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    Process.send_after(self(), :update_live_view, 1000)
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
    |> assign(:virtualmachines, list_virtualmachines())
  end

  defp apply_action(socket, :start, %{"name" => name}) do

    IO.inspect("starting VM #{name}")
    VirtualMachineController.start_virtual_machine(name)

    push_redirect(socket, to: "/virtualmachines/")

    socket
    |> assign(:page_title, "Start Virtual Machine")
    |> assign(:virtual_machine, nil)
    |> assign(:virtualmachines, list_virtualmachines())
  end

  defp apply_action(socket, :stop, %{"name" => name}) do

    IO.inspect("stopping VM #{name}")
    VirtualMachineController.stop_virtual_machine(name)

    push_redirect(socket, to: "/virtualmachines/")

    socket
    |> assign(:page_title, "Listing Virtual machines")
    |> assign(:virtual_machine, nil)
    |> assign(:virtualmachines, list_virtualmachines())
  end

  @doc """
    Handles event when "Batch Start" is clicked
  """
  def handle_event("batch-start", _param, socket) do

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

  def handle_info(:update_live_view, socket) do
    Process.send_after(self(), :update_live_view, 1000)
    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

end
