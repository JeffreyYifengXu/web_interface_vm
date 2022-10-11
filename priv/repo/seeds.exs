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

AzureBillingDashboard.Accounts.register_user(%{
  email: "user1@company.com",
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
