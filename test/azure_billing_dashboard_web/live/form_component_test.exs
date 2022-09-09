defmodule FormComponentTest do
    use AzureBillingDashboardWeb.ConnCase
    use AzureBillingDashboardWeb, :live_component

    alias AzureBillingDashboard.List_VMs

    import Phoenix.LiveViewTest
    import AzureBillingDashboard.List_VMsFixtures

end
