defmodule AzureBillingDashboardWeb.VirtualMachineLiveTest do
  use AzureBillingDashboardWeb.ConnCase

  import Phoenix.LiveViewTest
  import AzureBillingDashboard.List_VMsFixtures

  @create_attrs %{cost_accrued: "some cost_accrued", cost_so_far: "some cost_so_far", name: "some name", process: "some process", status: "some status"}
  @update_attrs %{cost_accrued: "some updated cost_accrued", cost_so_far: "some updated cost_so_far", name: "some updated name", process: "some updated process", status: "some updated status"}
  @invalid_attrs %{cost_accrued: nil, cost_so_far: nil, name: nil, process: nil, status: nil}

  defp create_virtual_machine(_) do
    virtual_machine = virtual_machine_fixture()
    %{virtual_machine: virtual_machine}
  end

  describe "Index" do
    setup [:create_virtual_machine]

    test "lists all virtualmachines", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, _index_live, html} = live(conn, Routes.virtual_machine_index_path(conn, :index))

      assert html =~ "Listing Virtualmachines"
      assert html =~ virtual_machine.cost_accrued
    end

    test "saves new virtual_machine", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.virtual_machine_index_path(conn, :index))

      assert index_live |> element("a", "New Virtual machine") |> render_click() =~
               "New Virtual machine"

      assert_patch(index_live, Routes.virtual_machine_index_path(conn, :new))

      assert index_live
             |> form("#virtual_machine-form", virtual_machine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#virtual_machine-form", virtual_machine: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.virtual_machine_index_path(conn, :index))

      assert html =~ "Virtual machine created successfully"
      assert html =~ "some cost_accrued"
    end

    test "updates virtual_machine in listing", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, index_live, _html} = live(conn, Routes.virtual_machine_index_path(conn, :index))

      assert index_live |> element("#virtual_machine-#{virtual_machine.id} a", "Edit") |> render_click() =~
               "Edit Virtual machine"

      assert_patch(index_live, Routes.virtual_machine_index_path(conn, :edit, virtual_machine))

      assert index_live
             |> form("#virtual_machine-form", virtual_machine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#virtual_machine-form", virtual_machine: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.virtual_machine_index_path(conn, :index))

      assert html =~ "Virtual machine updated successfully"
      assert html =~ "some updated cost_accrued"
    end

    test "deletes virtual_machine in listing", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, index_live, _html} = live(conn, Routes.virtual_machine_index_path(conn, :index))

      assert index_live |> element("#virtual_machine-#{virtual_machine.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#virtual_machine-#{virtual_machine.id}")
    end
  end

  describe "Show" do
    setup [:create_virtual_machine]

    test "displays virtual_machine", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, _show_live, html} = live(conn, Routes.virtual_machine_show_path(conn, :show, virtual_machine))

      assert html =~ "Show Virtual machine"
      assert html =~ virtual_machine.cost_accrued
    end

    test "updates virtual_machine within modal", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, show_live, _html} = live(conn, Routes.virtual_machine_show_path(conn, :show, virtual_machine))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Virtual machine"

      assert_patch(show_live, Routes.virtual_machine_show_path(conn, :edit, virtual_machine))

      assert show_live
             |> form("#virtual_machine-form", virtual_machine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#virtual_machine-form", virtual_machine: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.virtual_machine_show_path(conn, :show, virtual_machine))

      assert html =~ "Virtual machine updated successfully"
      assert html =~ "some updated cost_accrued"
    end
  end
end
