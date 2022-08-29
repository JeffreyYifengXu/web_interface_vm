defmodule AzureBillingDashboard.List_VMsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AzureBillingDashboard.List_VMs` context.
  """

  @doc """
  Generate a virtual_machine.
  """
  def virtual_machine_fixture(attrs \\ %{}) do
    {:ok, virtual_machine} =
      attrs
      |> Enum.into(%{
        cost_accrued: "some cost_accrued",
        cost_so_far: "some cost_so_far",
        name: "some name",
        process: "some process",
        status: "some status"
      })
      |> AzureBillingDashboard.List_VMs.create_virtual_machine()

    virtual_machine
  end
end
