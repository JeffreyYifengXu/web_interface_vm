defmodule AzureBillingDashboard do
  @moduledoc """
  AzureBillingDashboard keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def list do
    azure_api = "https://management.azure.com/subscriptions/"
    subscription_ID = "f325fdb6-ed61-4541-9591-533db4315802"
    resource_group_name = "COMP3888_VMs"
    "#{azure_api}/#{subscription_ID}/resourceGroups/#{resource_group_name}/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01"
  end
end
