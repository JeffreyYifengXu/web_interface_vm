defmodule AzureBillingDashboardWeb.PageView do
  use AzureBillingDashboardWeb, :view

  def render("index.html", assigns) do
    "rendering with assigns #{inspect Map.keys(assigns)}"
  end
end
