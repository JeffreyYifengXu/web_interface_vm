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
  def mount(_params, session, socket) do
    # socket = assign_defaults(_session, socket)
    # {:ok, assign(socket, query: "", results: %{})}
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

  @doc """
  Converts a string representation of a date and converts it into a NaiveDateTime Object

  Eg. "20221001" -> [2022-10-01 00:00:00]
  """
  def convert_int_to_date(<<yyyy::binary-4, mm::binary-2, dd::binary-2>>) do
    [yyyy, mm, dd] = for i <- [yyyy, mm, dd], do: String.to_integer(i)

    date = NaiveDateTime.new!(yyyy, mm, dd, 0, 0, 0)
    date
  end

  @doc """
  Creates a LinePlot from the dataset given.
  """
  def create_graph(dataset, options \\ []) do
    if(dataset == nil) do
      IO.puts("\n\nDATASET EMPTY\n\n")
      dataset = %{}
    end

    ls = Map.to_list(dataset)

    ds = Dataset.new(ls, ["x", "y"])

    # scale = Contex.TimeScale.new()
    # Contex.TimeScale.add_interval(scale, :days, 2)

    if(options != []) do
      options = [
        smoothed: true,
        colour_palette: :default,
      ]
    end

    plot = Plot.new(ds, LinePlot, 500, 400, options)
      |> Plot.titles("VM Costs over time", "")
      |> Plot.axis_labels("Day", "Cost (Dollars)")
    Plot.to_svg(plot)
  end

  @doc """
  Converts a list of data into a map of key-value pairs

  Used to generate the map that is used to display the cost data on the VM details page
  key = date
  value = cost
  """
  def create_map_from_data(data, idx_of_key, idx_of_value) do
    map = Enum.reduce(data, %{}, fn x, acc ->
      date = convert_int_to_date(Integer.to_string(Enum.at(x, idx_of_key)))
      cost = Enum.at(x, idx_of_value)

      output = Map.fetch(acc, date)

      if(output != :error) do
        Map.update(acc, date, cost, fn exs_val -> exs_val + cost end)
      else
        Map.put(acc, date, cost)
      end
    end)

    map
  end

  @doc """
  Function responsible for merging multiple maps together

  Used to combine the three seperate data maps into one
  Final map is used to store the data used by the graph
  """
  def merge_into_single_map(disk_data_map, ip_data_map, vm_data_map) do
    first_map = Map.merge(disk_data_map, ip_data_map, fn _k, v1, v2 ->
      v1 + v2
    end)

    combined_map = Map.merge(first_map, vm_data_map, fn _k, v1, v2 ->
      v1 + v2
    end)

    combined_map
  end

  @doc """
  Function responsible for creating the map that will be used to store the data used by the graph
  """
  def create_general_map(disk_data, ip_data, vm_data) do
    disk_data_map = create_map_from_data(disk_data, 1, 0)
    ip_data_map = create_map_from_data(ip_data, 1, 0)
    vm_data_map = create_map_from_data(vm_data, 1, 0)

    final_map = merge_into_single_map(disk_data_map, ip_data_map, vm_data_map)

    final_map
  end

  def get_and_filter_data(vm) do
    data = AzureAPI.VirtualMachineController.get_cost_data(vm)

    disk_data = Enum.filter(data["properties"]["rows"], fn x -> String.contains?(Enum.at(x, 2), "disk") end)
    ip_data = Enum.filter(data["properties"]["rows"], fn x -> String.ends_with?(Enum.at(x, 2), "ip") end)
    vm_data = Enum.filter(data["properties"]["rows"], fn x -> String.contains?(Enum.at(x, 2), String.downcase("/virtualmachines/#{vm.name}") ) end)

    {disk_data, ip_data, vm_data}
  end

  @doc """
  Function responsible for updating the cost_accrued for the selected vm with the data given

  Does this by summing up the values of the data map, rounding to 4 points of precision, and then updating the DB/Repo
  """
  def update_cost_accrued(vm, data_map) do
    sum = Enum.sum(Map.values(data_map))
    sum = Float.round(sum, 2)
    sum = "#{sum}"
    AzureBillingDashboard.List_VMs.update_virtual_machine(vm, %{cost_accrued: sum})
  end

  @doc """
  Function responsible for creating the graph that is displayed on the VM details page

  Also updates the cost_accrued data for the selected vm with vm.id = id
  """
  def plot_cost_data_graph(id) do
    vm = List_VMs.get_virtual_machine!(id)

    {disk_data, ip_data, vm_data} = get_and_filter_data(vm)

    final_map = create_general_map(disk_data, ip_data, vm_data)
    IO.inspect(final_map)

    update_cost_accrued(vm, final_map)

    graph = create_graph(final_map)
    graph
  end

  def handle_info({:update_live_view, id}, socket) do
    Process.send_after(self(), {:update_live_view, id}, 5000)
    {:noreply, assign(socket, :virtualmachines, List_VMs.get_virtual_machine!(id))}
  end

end
