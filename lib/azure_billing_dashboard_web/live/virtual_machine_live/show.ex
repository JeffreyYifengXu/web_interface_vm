defmodule AzureBillingDashboardWeb.VirtualMachineLive.Show do
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs

  alias Contex.{BarChart, Plot, Dataset, PointPlot}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
    {:ok, socket}
  end

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

  def test_data() do
    data = 10
  end

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
