defmodule AzureBillingDashboardWeb.VirtualMachineLive.Index do
  use AzureBillingDashboardWeb, :live_view

  alias AzureBillingDashboard.List_VMs
  alias AzureBillingDashboard.List_VMs.VirtualMachine
  alias AzureBillingDashboard.Repo

  @impl true
  def mount(_params, _session, socket) do
    # socket = assign_defaults(session, socket)
    # {:ok, assign(socket, query: "", results: %{})}
    {:ok, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Virtual machine")
    |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Virtual machine")
    |> assign(:virtual_machine, %VirtualMachine{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Virtual machines")
    |> assign(:virtual_machine, nil)
  end

  # @impl true
  # def handle_event("start all", %{"id" => id}, socket) do
  #   virtual_machine = List_VMs.get_virtual_machine!(id)
  #   {:ok, _} = List_VMs.start_virtual_machine(virtual_machine)
  #
  #   {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  # end
  #
  # @impl true
  # def handle_event("stop all", %{"id" => id}, socket) do
  #     virtual_machine = List_VMs.get_virtual_machine!(id)
  #     {:ok, _} = List_VMs.stop_virtual_machine(virtual_machine)
  #
  #     {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  # end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    {:ok, _} = List_VMs.delete_virtual_machine(virtual_machine)

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  def handle_event("start", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    {:ok, _} = List_VMs.start_virtual_machine(virtual_machine)

    # {:noreply, assign(socket, :virtual_machine.process, 100)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  def handle_event("stop", %{"id" => id}, socket) do
    virtual_machine = List_VMs.get_virtual_machine!(id)
    {:ok, _} = List_VMs.stop_virtual_machine(virtual_machine)

    # {:noreply, assign(socket, :virtual_machine.process, 100)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  def handle_event("batch-start", _param, socket) do
    # {}
    # virtual_machine = List_VMs.get_virtual_machine!(id)
    virtual_machines = List_VMs.stopall_virtual_machine()
    for machine <- virtual_machines do
      List_VMs.start_virtual_machine(machine)
    end
    # {:noreply, assign(socket, :virtual_machine.process, 0)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  def handle_event("batch-stop", _param, socket) do
    # {}
    # virtual_machine = List_VMs.get_virtual_machine!(id)
    virtual_machines = List_VMs.stopall_virtual_machine()
    for machine <- virtual_machines do
      List_VMs.stop_virtual_machine(machine)
    end
    # {:noreply, assign(socket, :virtual_machine.process, 0)}

    {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}
  end

  # @impl true
  # def handle_event("start", %{"id" => id}, socket) do
  #   virtual_machine = List_VMs.get_virtual_machine!(id)
  #   changeset = VirtualMachine.changeset(virtual_machine, %{status: "Running"})
  #   # {:ok, _} = List_VMs.start_VM(virtual_machine)
  #   # Ecto.Changeset.change(virtual_machine, %{status: "Running"}) |> Repo.update!
  #   case Repo.update!(changeset) do:
  #     {:ok, virtual_machine} =

  #   {:ok, _}
  #   # = List_VMs.delete_virtual_machine(virtual_machine)

  #   {:noreply, assign(socket, :virtualmachines, list_virtualmachines())}

  # end

  defp list_virtualmachines do
    List_VMs.list_virtualmachines()
  end

  # defp apply_action(socket, :start, _params) do
  #   socket
  #   |> assign(:page_title, "Start VM")
  #   |> assign(:virtual_machine, List_VMs.get_virtual_machine!(id))
  # end

end
