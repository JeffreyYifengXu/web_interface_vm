defmodule AzureAPI.VirtualMachineController do

    # alias AzureBillingDashboard.List_VMs

    use GenServer

    ########### GENSERVER ####################################################
    ########## GENSERVER CLIENT ###############
    def start_link do
        GenServer.start_link(__MODULE__, [], name: :virtual_machine_controller)
    end

    def get_virtual_machines() do
      GenServer.call(:virtual_machine_controller, {:get_virtual_machines})
    end

	def get_availability() do
		GenServer.call(:virtual_machine_controller, {:get_availability})
	end

    def start_virtual_machine(name) do
      GenServer.call(:virtual_machine_controller, {:start_virtual_machine, name})
    end

    def stop_virtual_machine(name) do
        GenServer.call(:virtual_machine_controller, {:stop_virtual_machine, name})
    end

    def get_cost_data(name) do
        GenServer.call(:virtual_machine_controller, {:get_cost_data, name})
    end

    ########## GENSERVER SERVER CALLBACKS ########################

    # Callbacks
    def handle_call({:get_virtual_machines}, _from, data) do

        # Call list_VM endpoint
        {status, map} = list_azure_machines_and_statuses(data)

        if status == :ok do
            {:reply, map, data}
        else
            # pass new token
            token = get_token()

            # Run list again
            {_status, map} = list_azure_machines_and_statuses(token)

            {:reply, map, token}
        end
        # IO.inspect(body)

    end

	def handle_call({:get_availability}, _from, token) do
		# Call availability function
		data = get_availability(token)

		{:reply, data, token}
	end

    def handle_call({:start_virtual_machine, name}, _from, token) do

        # Call start endpoint
        start_azure_machine(name, token)

        {:reply, token, token}
        # IO.inspect(body)
    end

    def handle_call({:stop_virtual_machine, name}, _from, token) do

        # Call Start Function
        stop_azure_machine(name, token)

        {:reply, token, token}
    end

    def handle_call({:get_cost_data, name}, _from, token) do

        # Call Start Function
        data = get_azure_cost_data(name, token)

        {:reply, data, token}
    end

    def init(_) do
        token = get_token()
        {:ok, token}
    end

    ################ END GENSERVER #######################

    ################ API FUNCTIONS #######################

    def get_token() do
        # Call Token Endpoint
        HTTPoison.start
        response = HTTPoison.post! "https://login.microsoftonline.com/a6a9eda9-1fed-417d-bebb-fb86af8465d2/oauth2/token", "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]
        {_status, body} = Poison.decode(response.body)
        IO.inspect(body["error"])
        token = body["access_token"]
        IO.inspect(token)

        token
    end

    # LIST AZURE MACHINES
    def list_azure_machines_and_statuses(token) do
        # Construct Header
        header = ['Authorization': "Bearer " <> token]

        # Call List Endpoint
        response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01", header, []
        IO.inspect(response.status_code)
        if response.status_code == 200 do
            body = Poison.Parser.parse!(response.body)

            # Extract names
            names = Enum.map(body["value"], fn (x) -> x["name"] end)

            IO.inspect(names)

            map = Enum.map(names, fn name ->
                instance_view = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/instanceView?api-version=2022-03-01", header, []
                {_status, body} = Poison.decode(instance_view.body)
                [_provision, power] = Enum.map(body["statuses"], fn (x) -> x["displayStatus"] end)
                {name, power}
            end)

            {:ok, map}
        else
           {:error, response.status_code}
        end
<<<<<<< HEAD
    end
=======

    end

	# GET AZURE AVAILABILITIES

	def get_availability(token) do
		# Construct header
		header = ['Authorization': "Bearer " <> token]

		response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/providers/Microsoft.ResourceHealth/availabilityStatuses/current?api-version=2022-03-01", header, []

		IO.inspect(response.status_code)
		if response.status_code == 200 do
			body = Poison.Parser.parse!(response.body)
>>>>>>> ef7cb7088b1b31201d16dab542fd2b100bb1a4f5

			statuses = Enum.map(body["value"], fn (x) -> {x["properties"]["availabilityState"], x["properties"]["summary"]} end)
			IO.inspect(statuses)

			{:ok, statuses}
		else
			{:error, response.status_code}
		end
	end

    # START AZURE MACHINES

    def start_azure_machine(name, token) do

        # Construct Header
        header = ['Authorization': "Bearer " <> token]

        # Call Start Endpoint
        HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/start?api-version=2022-08-01", [], header
    end

    # STOP AZURE MACHINES

    def stop_azure_machine(name, token) do

        # Construct Header
        header = ['Authorization': "Bearer " <> token]

        # Call Start Endpoint
        HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/powerOff?api-version=2022-08-01", [], header
    end

    # GET COST DATA
    """
    TO CALL THIS FUNCTION, CALL THE GENSERVER FUNCTION

    For example, needed in the details page

    eg -> response = AzureAPI.VirtualMachineController.get_cost_data(vmName).
    get_cost_data/1 grabs the token from the genserver and sends it to this function along with the vmName
    """

    def get_azure_cost_data(name, token) do

        # Construct Header
        header = ['Authorization': "Bearer " <> token, 'content-type': "application/json"]

        scope = "subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a"

        body = %{
            :type => "Usage",
            :timeframe => "MonthToDate",
            :dataset => %{
                :granularity => "Daily",
                :filter => %{
                    :dimensions => %{
                        :name => "ResourceId",
                        :operator => "In",
                        :values => [
                            "/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourcegroups/usyd-12a/providers/microsoft.compute/virtualmachines/#{name}"
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

        # Call Start Endpoint
        response = HTTPoison.post! "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01", Poison.encode!(body), header

        # Return decoded body
        Poison.decode! response.body
        # "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01"

    end
end
