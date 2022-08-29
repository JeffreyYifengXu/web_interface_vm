defmodule AzureBillingDashboard.Repo do
  use Ecto.Repo,
    otp_app: :azure_billing_dashboard,
    adapter: Ecto.Adapters.Postgres
end
