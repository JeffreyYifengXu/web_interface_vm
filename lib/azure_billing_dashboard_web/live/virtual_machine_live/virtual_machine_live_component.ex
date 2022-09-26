defmodule AzureBillingDashboardWeb.VirtualMachineLive.VirtualMachineLiveComponent do
  use AzureBillingDashboardWeb, :live_component

  alias AzureAPI.VirtualMachineController
  alias AzureBillingDashboard.List_VMs

  def render(assigns) do
    IO.puts("Rendering")
    IO.inspect(assigns.post.__meta__.state)
    ~L"""
    <tr id={"virtual_machine-#{@virtual_machine.id}"}>


          <td style="word-break: break-all"><%= @virtual_machine.name %></td>
          <td>
              <div class="meter">
                  <span style={"width: #{@virtual_machine.process}%"}>
                      <%= @virtual_machine.process %>%
                  </span>
              </div>
              <div class="meter">
                  <span style={"width: #{@virtual_machine.process}%"}>
                      <%= @virtual_machine.process %>%
                  </span>
              </div>
          </td>

          <td> <%= @virtual_machine.status %> </td>

          <td><%= @virtual_machine.cost_so_far %></td>

          <td style="display:grid; grid-template-columns:1fr; width: 100%">
                <span><%= live_redirect "Details", to: Routes.virtual_machine_show_path(@socket, :show, @virtual_machine), class: "button-2" %></span>

            <%= if String.contains?(@virtual_machine.status, "running") or String.contains?(@virtual_machine.status, "start") do %>
                  <span style="color:#FFFFFF;"><%= link "Stop", to: "#", phx_click: "stop", phx_value_id: @virtual_machine.id, class: "button-2" %></span>
            <% end %>
            <%= if String.contains?(@virtual_machine.status, "deallocated") or String.contains?(@virtual_machine.status, "stop") do %>
                  <span><%= link "Start", to: "#", phx_click: "start", phx_value_id: @virtual_machine.id, class: "button-2" %></span>
            <% end %>
                <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @virtual_machine.id, data: [confirm: "Are you sure?"], class: "button-3" %></span>
          </td>
    </tr>
    """
  end

  @doc """
    Handles event when "Start" is clicked
  """
  def handle_event("start", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    VirtualMachineController.start_virtual_machine(virtual_machine.name)

    # Process.send_after(self(), :update_live_view, socket, 1000)

    # {:noreply, assign(socket, :@virtual_machine.process, 100)}

    {:noreply, assign(socket, :virtualmachines, List_VMs.list_virtualmachines())}
  end

  @doc """
    Handles event when "Stop" is clicked
  """
  def handle_event("stop", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    VirtualMachineController.stop_virtual_machine(virtual_machine.name)

    # {:noreply, assign(socket, :@virtual_machine.process, 100)}

    {:noreply, assign(socket, :virtualmachines, List_VMs.list_virtualmachines())}
  end

    @doc """
      Handles event when "Delete" is clicked
    """
    @impl true
    def handle_event("delete", %{"id" => id}, socket) do
      virtual_machine = List_VMs.get_virtual_machine!(id)
      {:ok, _} = List_VMs.delete_virtual_machine(virtual_machine)

      # Process.send_after(self(), :update_live_view, socket, 1000)

      {:noreply, assign(socket, :virtualmachines, List_VMs.list_virtualmachines())}
    end
end
