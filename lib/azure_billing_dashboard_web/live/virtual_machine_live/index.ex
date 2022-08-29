defmodule AzureBillingDashboardWeb.VirtualMachineLive.Index do
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs
  alias AzureBillingDashboard.List_VMs.VirtualMachine

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
    |> assign(:page_title, "Listing Virtualmachines")
    |> assign(:virtual_machine, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    {:ok, _} = List_VMs.delete_virtual_machine(virtual_machine)

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  defp list_virtualmachines do
    List_VMs.list_virtualmachines()
  end
end
