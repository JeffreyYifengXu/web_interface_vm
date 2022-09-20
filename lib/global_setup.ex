defmodule GlobalSetup do
  @moduledoc """
  Module for  global setup(seeds file for user auth) that needs to be executed
  on Fly.io that cannot just have done in the Dockerfile.

  For new fly.io server, ssh to the iex console after "fly depoly" using:
  - fly ssh establish (one time)
  - fly ssh issue --agent (one time)
  - fly ssh console
  - app/bin/azure_billing_dashboard remote

  then run the GlobalSetup.run in the iex console by: "GlobalSetup.run"

  """

  def run do
    AzureBillingDashboard.Accounts.register_user(%{
      email: "user1@company.com",
      password: "123456789abc",
      password_confirmation: "123456789abc"
      # id: "memfhsidfhkd"
    })
  end
end
