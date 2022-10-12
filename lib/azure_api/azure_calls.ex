defmodule AzureAPI.AzureCalls do

    @moduledoc """
    API functions to call:

        1. Token
        2. List Machines and Statuses
        3. Get VM Availability
        4. Start Machine
        5. Stop Machine
        6. Get Cost Data
    """

    use AzureBillingDashboardWeb, :live_view

    import Ecto.Query, warn: false
    alias AzureBillingDashboard.Repo
    alias AzureBillingDashboard.List_VMs
    alias AzureBillingDashboard.List_VMs.VirtualMachine

    ################ API FUNCTIONS #######################

    @doc """
    Retrives access token from Azure.

    Token expires every hour so it buffers a :refresh_token message back to
    the genserver every 60 minutes.

    Returns token
    """

    def get_token(azure_keys) do
        # Call Token Endpoint
        HTTPoison.start
        response = HTTPoison.post! "https://login.microsoftonline.com/#{Map.get(azure_keys, "tenant_id")}/oauth2/token", "grant_type=client_credentials&client_id=#{Map.get(azure_keys, "client_id")}&client_secret=#{Map.get(azure_keys, "client_secret")}&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]
        {_status, body} = Poison.decode(response.body)
        # IO.inspect(body["error"])
        token = body["access_token"]
        IO.inspect(token)

        # Schedule a new token after 1 hour
        Process.send_after(:virtual_machine_controller, :refresh_token, 1 * 60 * 60 * 1000)

        token
    end

    # LIST AZURE MACHINES
    def list_azure_machines_and_statuses(azure_keys) do
        # Construct Header
        # IO.inspect(Map.get(azure_keys, "token"))
        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token")]

        # Call List Endpoint
        response = HTTPoison.get! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/resourceGroups/#{Map.get(azure_keys, "resource_group")}/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01", header, []

        IO.inspect(response.status_code)
        if response.status_code == 200 do
            body = Poison.Parser.parse!(response.body)
            IO.inspect(body)

            # Extract names
            names = Enum.map(body["value"], fn (x) -> x["name"] end)

            map = Enum.map(names, fn name ->
                instance_view = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/instanceView?api-version=2022-03-01", header, []
                {_status, body} = Poison.decode(instance_view.body)
                [_provision, power] = Enum.map(body["statuses"], fn (x) -> x["displayStatus"] end)
                os_disk = Enum.map(body["disks"], fn (x) -> x["name"] end)
                {name, power, os_disk}
            end)

            # Save to repo
            for item <- map do
                {name, power, os_disk} = item

                if Repo.exists?(from vm in VirtualMachine, where: vm.name == ^name) do
                    # Get Machine
                    virtual_machine = Repo.get_by(VirtualMachine, [name: name])
                    |> List_VMs.update_virtual_machine(%{name: name, status: power, odisk_name: List.first(os_disk)})
                else
                    # Create Virtual Machine
                    List_VMs.create_virtual_machine(%{name: name, status: power, odisk_name: List.first(os_disk)})
                end
            end

            # Process.send_after(:virtual_machine_controller, :refresh_sync, 1000)

            # assign(socket, :virtualmachines, List_VMs.list_virtualmachines())

            {:ok, map}
        else
           {:error, response.status_code}
        end
    end


	# GET AZURE AVAILABILITIES

	def get_availability(azure_keys) do

        IO.inspect("GETTING AVAILABILITY ----------------------------------")
		# Construct header
		header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token"), 'content-type': "application/json"]


        response = HTTPoison.get! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/providers/Microsoft.ResourceHealth/availabilityStatuses/current?api-version=2018-07-01", header, []

		# response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2018-07-01&", header, []


        IO.inspect(response)
		if response.status_code == 200 do
			body = Poison.Parser.parse!(response.body)

			statuses = Enum.map(body["value"], fn (x) -> {x["id"], x["properties"]["availabilityState"], x["properties"]["summary"]} end)
			IO.inspect(statuses)

			# statuses = Enum.map(body["value"], fn (x) -> {x["properties"]["availabilityState"], x["properties"]["summary"]} end)
			# IO.inspect(statuses)

            # Save to repo
            for item <- statuses do
                {name, availability, summary} = item

                if Repo.exists?(from vm in VirtualMachine, where: vm.name == ^name) do
                    # Get Machine
                    virtual_machine = Repo.get_by(VirtualMachine, [name: name])
                    |> List_VMs.update_virtual_machine(%{availability: availability})
                else
                    # Create Virtual Machine
                    # List_VMs.create_virtual_machine(%{name: name})
                end
            end

			{:ok, statuses}
		else
			{:error, response.status_code}
		end
	end

    # START AZURE MACHINES

    def start_azure_machine(name, azure_keys) do

        # Construct Header
        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token")]

        # Call Start Endpoint
        HTTPoison.post! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/resourceGroups/#{Map.get(azure_keys, "resource_group")}/providers/Microsoft.Compute/virtualMachines/#{name}/start?api-version=2022-08-01", [], header
    end

    # STOP AZURE MACHINES

    def stop_azure_machine(name, azure_keys) do

        # Construct Header
        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token")]

        # Call Start Endpoint
        HTTPoison.post! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/resourceGroups/#{Map.get(azure_keys, "resource_group")}/providers/Microsoft.Compute/virtualMachines/#{name}/powerOff?api-version=2022-08-01", [], header
    end

    # GET COST DATA

    @doc """
    TO CALL THIS FUNCTION, CALL THE GENSERVER FUNCTION

    For example, needed in the details page

    eg -> response = AzureAPI.VirtualMachineController.get_cost_data(vmName).
    get_cost_data/1 grabs the token from the genserver and sends it to this function along with the vmName
    """
    def get_azure_cost_data(name, azure_keys) do

        # Construct Header
        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token"), 'content-type': "application/json"]

        scope = "subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a"

        date = NaiveDateTime.local_now()
        date = NaiveDateTime.to_date(date)
        date = Date.to_string(date)

        body = %{
            :type => "Usage",
            :timeframe => "Custom",
            :timePeriod => %{
                :from => "2022-09-06",
                :to => date
            },
            :dataset => %{
                :granularity => "Daily",
                :filter => %{
                    :dimensions => %{
                        :name => "ResourceId",
                        :operator => "In",
                        :values => [
                            "/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourcegroups/usyd-12a/providers/microsoft.compute/virtualmachines/#{name.name}",
                            "/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourcegroups/usyd-12a/providers/microsoft.compute/disks/#{name.odisk_name}",
                            "/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourcegroups/usyd-12a/providers/microsoft.network/publicipaddresses/#{name.name}-ip"
                        ]
                    }
                },
                :grouping => [
                    %{
                        :type => "Dimension",
                        :name => "ResourceId"
                    }
                ],
                :aggregation => %{
                    :totalCost => %{
                        :name => "PreTaxCost",
                        :function => "sum"
                    }
                }
            }
        }

        options = [recv_timeout: 100000]

        # Call Start Endpoint
        response = HTTPoison.post! "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01", Poison.encode!(body), header, options

        # Return decoded body
        Poison.decode! response.body
        # "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01"
    end
end
