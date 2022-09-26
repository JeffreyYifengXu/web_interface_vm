defmodule AzureBillingDashboardWeb.PageController do
  use AzureBillingDashboardWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
    # LiveView.Controller.live_render(conn, AzureBillingDashboardWeb.VirtualMachineLive.Index, session: %{})
  end
end
