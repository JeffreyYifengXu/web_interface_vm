# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AzureBillingDashboard.Repo.insert!(%AzureBillingDashboard.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
AzureBillingDashboard.Accounts.register_admin(%{
  email: "admin@company.com",
  password: "123456789abc",
  password_confirmation: "123456789abc"
})

AzureBillingDashboard.Accounts.register_user(%{
  email: "user1@company.com",
  password: "123456789abc",
  password_confirmation: "123456789abc"
})

AzureBillingDashboard.Accounts.register_user(%{
  email: "user2@company.com",
  password: "123456789abc",
  password_confirmation: "123456789abc"
})
