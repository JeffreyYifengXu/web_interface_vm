defmodule AzureBillingDashboardWeb.PageController do
  use AzureBillingDashboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
