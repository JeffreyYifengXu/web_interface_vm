defmodule AzureBillingDashboardWeb.VirtualMachineLive.FormComponent do
  use AzureBillingDashboardWeb, :live_component

  alias AzureBillingDashboard.List_VMs

  @impl true
  def update(%{virtual_machine: virtual_machine} = assigns, socket) do
    changeset = List_VMs.change_virtual_machine(virtual_machine)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"virtual_machine" => virtual_machine_params}, socket) do
    changeset =
      socket.assigns.virtual_machine
      |> List_VMs.change_virtual_machine(virtual_machine_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"virtual_machine" => virtual_machine_params}, socket) do
    save_virtual_machine(socket, socket.assigns.action, virtual_machine_params)
  end

  defp save_virtual_machine(socket, :edit, virtual_machine_params) do
    case List_VMs.update_virtual_machine(socket.assigns.virtual_machine, virtual_machine_params) do
      {:ok, _virtual_machine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Virtual machine updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_virtual_machine(socket, :new, virtual_machine_params) do
    case List_VMs.create_virtual_machine(virtual_machine_params) do
      {:ok, _virtual_machine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Virtual machine created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # defp save_virtual_machine(socket, :start, virtual_machine_params) do
  #   case List_VMs.start_virtual_machine(socket.assigns.virtual_machine, virtual_machine_params) do
  #     {:ok, _virtual_machine} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Virtual machine updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

end
