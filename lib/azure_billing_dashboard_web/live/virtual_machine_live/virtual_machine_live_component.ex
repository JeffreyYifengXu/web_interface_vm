defmodule AzureBillingDashboardWeb.VirtualMachineLive.VirtualMachineLiveComponent do
  use AzureBillingDashboardWeb, :live_component

  alias AzureAPI.VirtualMachineController
  alias AzureBillingDashboard.List_VMs

  def render(assigns) do
    IO.puts("Rendering")
    ~H"""
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

        <td>
            <%= if String.contains?(@virtual_machine.status, "running") or String.contains?(@virtual_machine.status, "start") do %>
                  <div class="status-start">
                    <%= @virtual_machine.status %>
                  </div>
            <% end %>
            <%= if String.contains?(@virtual_machine.status, "deallocated") or String.contains?(@virtual_machine.status, "stop") do %>
                <div class="status-stop">
                    <%= @virtual_machine.status %>
                </div>
            <% end %>
        </td>

        <td><%= @virtual_machine.cost_so_far %></td>

        <td style="display:grid; grid-template-columns:1fr; width: 100%">
            <span><%= live_redirect "Details", to: Routes.virtual_machine_show_path(@socket, :show, @virtual_machine), class: "button-2" %></span>

        <%= if String.contains?(@virtual_machine.status, "running") or String.contains?(@virtual_machine.status, "start") do %>
              <span><%= link "Stop", to: "#", phx_click: "stop", phx_value_id: @virtual_machine.id, class: "button-2" %></span>
        <% end %>
        <%= if String.contains?(@virtual_machine.status, "deallocated") or String.contains?(@virtual_machine.status, "stop") do %>
              <span><%= link "Start", to: "#", phx_click: "start", phx_value_id: @virtual_machine.id, class: "button-2" %></span>
        <% end %>
            <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @virtual_machine.id, data: [confirm: "Are you sure?"], class: "button-3" %></span>
        </td>
        
        
    </tr>
    """
  end
end
