defmodule AzureBillingDashboardWeb.PageController do
  use AzureBillingDashboardWeb, :controller

  def index(conn, _params) do

    # Place API Calls Here

    render(conn, "index.html")
  end
end
