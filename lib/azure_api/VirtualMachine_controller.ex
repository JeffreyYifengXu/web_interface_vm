defmodule AzureAPI.VirtualMachineController do

  @moduledoc """
  Interface for making API calls.
  Stores required information as a state in the genserver

  Client functions:
    1. Starts Genserver (upon loading VM page)
    2. List Machines and Statuses
    3. Get VM Availability
    4. Start Machine
    5. Stop Machine
    6. Get Cost Data
  """

  alias AzureAPI.AzureCalls

  use GenServer

  ########### GENSERVER ####################################################
  ########## GENSERVER CLIENT ###############

  @doc """

  """

  def start_link(user) do
      #IO.inspect(user.sub_id)
      GenServer.start_link(__MODULE__, user, name: :virtual_machine_controller)
  end

  def get_virtual_machines() do
    GenServer.call(:virtual_machine_controller, :get_virtual_machines)
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


    def get_cost_data(vm) do
        try do
            GenServer.call(:virtual_machine_controller, {:get_cost_data, vm}, 1000000)
          catch
            :exit, _ ->
              IO.puts("there was an error")
              start_link("TEST123")

            e ->
              IO.puts("Fail state because: #{e}")
              get_cost_data(vm)
          end
    end

  ########## GENSERVER SERVER CALLBACKS ########################

  # Callbacks
  def handle_call(:get_virtual_machines, _from, azure_keys) do

      # Call list_VM endpoint
      {_status, map} = AzureCalls.list_azure_machines_and_statuses(azure_keys)

      {:reply, map, azure_keys}
      # IO.inspect(body)
  end

def handle_call({:get_availability}, _from, token) do
  # Call availability function
  data = AzureCalls.get_availability(token)

  {:reply, data, token}
end

  def handle_call({:start_virtual_machine, name}, _from, token) do

      # Call start endpoint
      AzureCalls.start_azure_machine(name, token)

      {:reply, token, token}
      # IO.inspect(body)
  end

  def handle_call({:stop_virtual_machine, name}, _from, token) do

      # Call Start Function
      AzureCalls.stop_azure_machine(name, token)

      {:reply, token, token}
  end

    def handle_call({:get_cost_data, vm}, _from, token) do

      data = AzureCalls.get_azure_cost_data(vm, token)

      {:reply, data, token, 1000000}
    end

  # Refresh Token
  def handle_info(:refresh_token, azure_keys) do
    token = AzureCalls.get_token(azure_keys)
    {:noreply, azure_keys}
  end

  def handle_info(:refresh_sync, token) do
    IO.inspect("refreshing sync")


    {:ok, _map} = AzureCalls.list_azure_machines_and_statuses(token)

    {:noreply, token}
  end

  def init(user) do
      token_keys = %{"sub_id" => user.sub_id, "tenant_id" => user.tenant_id,
        "client_secret" => user.client_secret, "client_id" => user.client_id,
        "resource_group" => user.resource_group}
      token = AzureCalls.get_token(token_keys)
      # azure_keys = Map.put(token_keys ,:token, token)
      azure_keys = %{"sub_id" => user.sub_id, "tenant_id" => user.tenant_id,
        "client_secret" => user.client_secret, "client_id" => user.client_id,
        "resource_group" => user.resource_group, "token" => token}
      IO.inspect(Map.get(azure_keys, "token"))
      {:ok, _map} = AzureCalls.list_azure_machines_and_statuses(azure_keys)
      {:ok, azure_keys}

  end

  ################ END GENSERVER #######################

#     ################ API FUNCTIONS #######################

#     def get_token() do
#         # Call Token Endpoint
#         HTTPoison.start
#         response = HTTPoison.post! "https://login.microsoftonline.com/a6a9eda9-1fed-417d-bebb-fb86af8465d2/oauth2/token", "grant_type=client_credentials&client_id=4bcba93a-6e11-417f-b4dc-224b008a7385&client_secret=oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ&resource=https%3A%2F%2Fmanagement.azure.com%2F", [{"Content-Type", "application/x-www-form-urlencoded"}]
#         {_status, body} = Poison.decode(response.body)
#         IO.inspect(body["error"])
#         token = body["access_token"]
#         IO.inspect(token)

#         # Schedule a new token after 1 hour
#         Process.send_after(:virtual_machine_controller, :refresh_token, 1 * 60 * 60 * 1000)

#         token
#     end

#     # LIST AZURE MACHINES
#     def list_azure_machines_and_statuses(token) do
#         # Construct Header
#         header = ['Authorization': "Bearer " <> token]

#         # Call List Endpoint
#         response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01", header, []
#         IO.inspect(response.status_code)
#         if response.status_code == 200 do
#             body = Poison.Parser.parse!(response.body)

#             # Extract names
#             names = Enum.map(body["value"], fn (x) -> x["name"] end)

#             IO.inspect(names)

#             map = Enum.map(names, fn name ->
#                 instance_view = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/instanceView?api-version=2022-03-01", header, []
#                 {_status, body} = Poison.decode(instance_view.body)
#                 [_provision, power] = Enum.map(body["statuses"], fn (x) -> x["displayStatus"] end)
#                 {name, power}
#             end)

#             {:ok, map}
#         else
#            {:error, response.status_code}
#         end
#     end


# 	# GET AZURE AVAILABILITIES

# 	def get_availability(token) do
# 		# Construct header
# 		header = ['Authorization': "Bearer " <> token]


#         response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/providers/Microsoft.ResourceHealth/availabilityStatuses/current?api-version=2018-07-01", header, []

# 		# response = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2018-07-01&", header, []


#         IO.inspect(response)
# 		if response.status_code == 200 do
# 			body = Poison.Parser.parse!(response.body)

# 			statuses = Enum.map(body["value"], fn (x) -> {x["properties"]["availabilityState"], x["properties"]["summary"]} end)
# 			IO.inspect(statuses)

# 			{:ok, statuses}
# 		else
# 			{:error, response.status_code}
# 		end
# 	end

#     # START AZURE MACHINES

#     def start_azure_machine(name, token) do

#         # Construct Header
#         header = ['Authorization': "Bearer " <> token]

#         # Call Start Endpoint
#         HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/start?api-version=2022-08-01", [], header
#     end

#     # STOP AZURE MACHINES

#     def stop_azure_machine(name, token) do

#         # Construct Header
#         header = ['Authorization': "Bearer " <> token]

#         # Call Start Endpoint
#         HTTPoison.post! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/powerOff?api-version=2022-08-01", [], header
#     end

#     # GET COST DATA
#     """
#     TO CALL THIS FUNCTION, CALL THE GENSERVER FUNCTION

#     For example, needed in the details page

#     eg -> response = AzureAPI.VirtualMachineController.get_cost_data(vmName).
#     get_cost_data/1 grabs the token from the genserver and sends it to this function along with the vmName
#     """

#     def get_azure_cost_data(name, token) do

#         # Construct Header
#         header = ['Authorization': "Bearer " <> token, 'content-type': "application/json"]

#         scope = "subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a"

#         body = %{
#             :type => "Usage",
#             :timeframe => "MonthToDate",
#             :dataset => %{
#                 :granularity => "Daily",
#                 :filter => %{
#                     :dimensions => %{
#                         :name => "ResourceId",
#                         :operator => "In",
#                         :values => [
#                             "/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourcegroups/usyd-12a/providers/microsoft.compute/virtualmachines/#{name}"
#                         ]
#                     }
#                 },
#                 :grouping => [
#                     %{
#                         :type => "Dimension",
#                         :name => "ResourceId"
#                     }
#                 ],
#                 :aggregation => %{
#                     :totalCost => %{
#                         :name => "PreTaxCost",
#                         :function => "sum"
#                     }
#                 }
#             }
#         }

#         # Call Start Endpoint
#         response = HTTPoison.post! "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01", Poison.encode!(body), header

#         # Return decoded body
#         Poison.decode! response.body
#         # "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01"
#     end
end
