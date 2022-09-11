defmodule AzureBillingDashboardWeb.VirtualMachineLive.Show do
  @moduledoc """
  This is the module responsible for sending data to the "show.html.heex" file.
  This file is the details page for an indiviudal virtual machine.
  """
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs

  alias Contex.{BarChart, Plot, Dataset, PointPlot}

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
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))
     |> assign(:graph, test_plot())
     |> assign(:test, test_data())
    }
  end

  defp page_title(:show), do: "Show Virtual machine"
  defp page_title(:edit), do: "Edit Virtual machine"

  @doc """
  Function used to send test data to our webpage.
  Currently being used by the ChartJS graphing library.
  """
  def test_data() do
    data = 20
  end


  @doc """
  Function being used to test the ContEx grahing library.
  Creates the data and returns a BarChart that will be displayed on the webpage.
  """
  def test_plot() do
    data = [{"Jan", 250}, {"Feb", 50}, {"Mar", 301}, {"Apr", 267}, {"May", 200}]
    ds = Dataset.new(data, ["x", "y"])

    options = [
      type: :stacked,
      orientation: :vertical,
      phx_event_handler: "chart1_bar_clicked",
    ]

    plot = Plot.new(ds, BarChart, 500, 400, options)
      |> Plot.titles("VM Costs over time", "")
      |> Plot.axis_labels("Month", "Cost (Dollars)")

      Plot.to_svg(plot)
  end

end
