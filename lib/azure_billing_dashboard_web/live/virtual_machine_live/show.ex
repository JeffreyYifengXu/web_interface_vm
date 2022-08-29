defmodule AzureBillingDashboardWeb.VirtualMachineLive.Show do
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))}
  end

  defp page_title(:show), do: "Show Virtual machine"
  defp page_title(:edit), do: "Edit Virtual machine"
end
