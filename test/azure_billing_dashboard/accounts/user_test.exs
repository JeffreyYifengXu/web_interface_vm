defmodule AzureBillingDashboard.ShowTest do
    alias AzureBillingDashboard.Accounts.User

    use AzureBillingDashboardWeb.ConnCase
    use Ecto.Schema
2
    import Ecto.Changeset
    import Phoenix.LiveViewTest

    @valid_attrs %{email: "musasrd@hotmail.com", password: "afd"}
    @invalid_attrs %{email: "musasrdhotmail.com"}

    describe "user testing" do

        test "changeset with valid attributes" do
            changeset = User.changeset(%User{}, @valid_attrs)
            assert changeset.valid?
        end

        test "changeset with invalid attributes" do
            changeset = User.changeset(%User{}, @invalid_attrs)
            assert changeset.valid?
        end
    end
    
    
end
