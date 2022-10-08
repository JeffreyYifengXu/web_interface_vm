defmodule AzureBillingDashboardWeb.VirtualMachineLive.Show do
  @moduledoc """
  This is the module responsible for sending data to the "show.html.heex" file.
  This file is the details page for an indiviudal virtual machine.
  """
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs

  alias Contex.{BarChart, Plot, Dataset, LinePlot}

  @doc """
  The LiveView entry point for this class.
  """
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
    {:ok, socket}
  end

  @doc """
  Function responsible for sending data to the webpage.
  The keyword "assign" sends the specified data to the html page which can then be retrieved via the key given (eg, key = "graph", value = "test_plot()")
  When the page is rendered, it replaces the key found in the html with the data contained in the value.
  """
  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    Process.send_after(self(), {:update_live_view, id}, 5000)
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))
     |> assign(:test, plot_cost_data_graph(id))
    }
  end

  defp page_title(:show), do: "Show Virtual machine"
  defp page_title(:edit), do: "Edit Virtual machine"

  def convert_int_to_date(<<yyyy::binary-4, mm::binary-2, dd::binary-2>>) do
    [yyyy, mm, dd] = for i <- [yyyy, mm, dd], do: String.to_integer(i)
    NaiveDateTime.new!(yyyy, mm, dd, 0, 0, 0)
  end

  @doc """
  Function used to send test data to our webpage.
  """
  def plot_cost_data_graph(id) do
    vm = List_VMs.get_virtual_machine!(id)
    data = AzureAPI.VirtualMachineController.get_cost_data(vm)

    disk_data = Enum.filter(data["properties"]["rows"], fn x -> String.contains?(Enum.at(x, 2), "disk") end)
    ip_data = Enum.filter(data["properties"]["rows"], fn x -> String.ends_with?(Enum.at(x, 2), "ip") end)
    vm_data = Enum.filter(data["properties"]["rows"], fn x -> String.contains?(Enum.at(x, 2), String.downcase("/virtualmachines/#{vm.name}") ) end)

    disk_data_map = %{}
    ip_data_map = %{}
    vm_data_map = %{}

    disk_data_map = Enum.reduce(disk_data, disk_data_map, fn x, acc ->
      cost = Enum.at(x,0)
      date = convert_int_to_date(Integer.to_string(Enum.at(x,1)))

      Map.put(acc, date, cost)
    end)

    ip_data_map = Enum.reduce(ip_data, ip_data_map, fn x, acc ->
      cost = Enum.at(x,0)
      date = convert_int_to_date(Integer.to_string(Enum.at(x,1)))

      output = Map.fetch(acc, date)

      if(output != :error) do
        Map.update(acc, date, cost, fn exs_val -> exs_val + cost end)
      else
        Map.put(acc, date, cost)
      end
    end)

    vm_data_map = Enum.reduce(vm_data, vm_data_map, fn x, acc ->
      cost = Enum.at(x,0)
      date = convert_int_to_date(Integer.to_string(Enum.at(x,1)))

      output = Map.fetch(acc, date)

      if(output != :error) do
        Map.update(acc, date, cost, fn exs_val -> exs_val + cost end)
      else
        Map.put(acc, date, cost)
      end
    end)

    map = Map.merge(disk_data_map, ip_data_map, fn _k, v1, v2 ->
      v1+v2
    end)

    final_map = Map.merge(map, vm_data_map, fn _k, v1, v2 ->
      v1+v2
    end)

    """
    CALCULATE TOTAL COST SO FAR
    UPDATE VALUE IN REPO
    """

    IO.inspect(final_map)

    ls = Map.to_list(final_map)

    ds = Dataset.new(ls, ["x", "y"])

    # scale = Contex.TimeScale.new()
    # Contex.TimeScale.add_interval(scale, :days, 2)

    options = [
      smoothed: true,
      colour_palette: :default,
    ]

    plot = Plot.new(ds, LinePlot, 500, 400, options)
      |> Plot.titles("VM Costs over time", "")
      |> Plot.axis_labels("Day", "Cost (Dollars)")
    Plot.to_svg(plot)
  end

  def handle_info({:update_live_view, id}, socket) do
    Process.send_after(self(), {:update_live_view, id}, 5000)
    {:noreply, assign(socket, :virtualmachines, List_VMs.get_virtual_machine!(id))}
  end

end
