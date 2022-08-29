defmodule AzureBillingDashboard.Repo.Migrations.CreateVirtualmachines do
  use Ecto.Migration

  def change do
    create table(:virtualmachines) do
      add :name, :string
      add :process, :string
      add :status, :string
      add :cost_so_far, :string
      add :cost_accrued, :string

      timestamps()
    end
  end
end
