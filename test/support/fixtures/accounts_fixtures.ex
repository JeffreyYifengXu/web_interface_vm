defmodule AzureBillingDashboard.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AzureBillingDashboard.List_VMs` context.
  """

  @doc """
  Generate a virtual_machine.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, virtual_machine} =
      attrs
      |> Enum.into(%{
        email: "user2@company.com",
        password: "123456789abc",
        password_confirmation: "123456789abc",
        sub_id: "f2b523ec-c203-404c-8b3c-217fa4ce341e",
        tenant_id: "a6a9eda9-1fed-417d-bebb-fb86af8465d2",
        client_secret: "oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ",
        client_id: "4bcba93a-6e11-417f-b4dc-224b008a7385",
        secrete_id: "95963713-b5f6-42d2-b91a-31acc90bbc95",
        object_id: "eff772c6-c116-4cb5-a4bd-088d5b65dd14",
        resource_group: "usyd-12a"
      })
      |> AzureBillingDashboard.List_VMs.create_virtual_machine()

    virtual_machine
  end
end
