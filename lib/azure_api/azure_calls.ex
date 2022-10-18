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

    # def iex_setup do
    #     azure_keys = %{"sub_id" => "f2b523ec-c203-404c-8b3c-217fa4ce341e", "tenant_id" => "a6a9eda9-1fed-417d-bebb-fb86af8465d2",
    #     "client_secret" => "oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ", "client_id" => "4bcba93a-6e11-417f-b4dc-224b008a7385",
    #     "resource_group" => "usyd-12a"}

    #     token = get_token(azure_keys)

    #     azure_keys = %{"sub_id" => "f2b523ec-c203-404c-8b3c-217fa4ce341e", "tenant_id" => "a6a9eda9-1fed-417d-bebb-fb86af8465d2",
    #     "client_secret" => "oNH8Q~Gw6j0DKSEkJYlz2Cy65AkTxiPsoSLWKbiZ", "client_id" => "4bcba93a-6e11-417f-b4dc-224b008a7385",
    #     "resource_group" => "usyd-12a", "token" => token}
    # end

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

        IO.inspect("################# Initizliase API Calls ##################")
        IO.inspect(body["error"])

        token = body["access_token"]
        IO.inspect(token)

        # Schedule a new token after 1 hour
        Process.send_after(:virtual_machine_controller, :refresh_token, 1 * 60 * 60 * 1000)

        token
    end

    # LIST AZURE MACHINES
    def list_azure_machines_and_statuses(azure_keys) do
        IO.inspect("\n\n############### List azure machines and statuses ###################\n\n")

        # Construct Header
        # IO.inspect(Map.get(azure_keys, "token"))
        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token")]

        # Call List Endpoint
        response = HTTPoison.get! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/resourceGroups/#{Map.get(azure_keys, "resource_group")}/providers/Microsoft.Compute/virtualMachines?api-version=2022-03-01", header, []

        if response.status_code == 200 do
            body = Poison.Parser.parse!(response.body)
            IO.inspect(body)
            # Extract names
            general_info = Enum.map(body["value"], fn (x) -> {x["name"], x["properties"]["hardwareProfile"]["vmSize"], x["location"], x["properties"]["storageProfile"]["osDisk"]["osType"], x["properties"]["billingProfile"]["maxPrice"]} end)

            IO.inspect(general_info)
            # IO.inspect(names)

            # IO.inspect(names)

            map = Enum.map(general_info, fn info ->
                {name, vmSize, location, osType, maxPrice} = info
                instance_view = HTTPoison.get! "https://management.azure.com/subscriptions/f2b523ec-c203-404c-8b3c-217fa4ce341e/resourceGroups/usyd-12a/providers/Microsoft.Compute/virtualMachines/#{name}/instanceView?api-version=2022-03-01", header, []
                {_status, body} = Poison.decode(instance_view.body)
                IO.inspect(body)
                os_disk = Enum.map(body["disks"], fn (x) -> x["name"] end)
                # status_update = body["vmAgent"]["statuses"]["time"]
                case Enum.map(body["statuses"], fn (x) -> x["displayStatus"] end) do
                    [_provision, power] -> {name, power, os_disk, vmSize, location, osType, maxPrice} # Most times there is a provisioning status and power status -> ["Provisioned", "VM Running"]
                    [power] -> {name, power, os_disk, vmSize, location, osType, maxPrice} # Sometimes there's only one status -> "Updating"
                end

            end)

            # Save to repo
            for item <- map do
                {name, power, os_disk, vmSize, location, osType, max_price} = item
                if Repo.exists?(from vm in VirtualMachine, where: vm.name == ^name) do
                    # Get Machine
                    Repo.get_by(VirtualMachine, [name: name])
                    |> List_VMs.update_virtual_machine(%{name: name, status: power, odisk_name: List.first(os_disk), vmSize: vmSize, location: location, os_type: osType, max_price: max_price})
                else
                    # Create Virtual Machine
                    List_VMs.create_virtual_machine(%{name: name, status: power, odisk_name: List.first(os_disk), vmSize: vmSize, location: location, os_type: osType, max_price: max_price})
                end
            end

            Process.send_after(:virtual_machine_controller, :refresh_sync, 1000)

            # assign(socket, :virtualmachines, List_VMs.list_virtualmachines())

            {:ok, map}
        else
           {:error, response.status_code}
        end
    end


    def get_availability(azure_keys) do
        IO.inspect("GETTING AVAILABILITY ----------------------------------")

        # #Obtain all current virtual machines from database
        vms = List_VMs.list_virtualmachines()

        url = "https://prices.azure.com/api/retail/prices?$filter="

        for vm <- vms do
            IO.inspect(vm.name)
            IO.inspect(vm.vmSize)

            if vm.max_price > 0 do
                # Construct filter element ["serviceName eq 'Virtual Machines' and armSkuName eq '#{vm.vmSize}' and 'armRegionName' eq '#{vm.location}'"]
                request_filter = "serviceName%20eq%20%27Virtual%20Machines%27%20and%20armSkuName%20eq%20%27#{vm.vmSize}%27%20and%20armRegionName%20eq%20%27#{vm.location}%27"
                request_url = url <> request_filter

                response = HTTPoison.get! request_url, [], []

                body = Poison.decode!(response.body)

                if String.contains?(vm.os_type, "Linux") do

                    spot_vms = Enum.filter(body["Items"], fn x ->
                        if String.contains?(Map.get(x, "skuName"), "Spot") and Map.get(x, "type") == "Consumption" and not String.contains?(x["productName"], "Windows") do
                            x
                        end
                    end)

                    IO.inspect("Linux")
                    IO.inspect(spot_vms)

                    if List.first(spot_vms)["unitPrice"] > vm.max_price do
                        List_VMs.update_virtual_machine(vm, %{availability: "Available", availability_summary: "Based on price only, this VM is available to run."})
                    else
                        List_VMs.update_virtual_machine(vm, %{availability: "Unavailable", availability_summary: "Based on price, this VM is unable to run."})
                    end

                else
                    spot_vms = Enum.filter(body["Items"], fn x ->
                        if String.contains?(Map.get(x, "skuName"), "Spot") and Map.get(x, "type") == "Consumption" and String.contains?(x["productName"], "Windows") do
                            x
                        end
                    end)

                    IO.inspect("Windows")
                    IO.inspect(spot_vms)

                    if List.first(spot_vms)["unitPrice"] > vm.max_price do
                        List_VMs.update_virtual_machine(vm, %{availability: "Available", availability_summary: "Based on price only, this VM is available to run."})
                    else
                        List_VMs.update_virtual_machine(vm, %{availability: "Unavailable", availability_summary: "Based on price, this VM is unable to run."})
                    end
                end


            else
                List_VMs.update_virtual_machine(vm, %{availability: "Unknown", availability_summary: "Eviction on capacity only, unable to determine availability."})
            end

        end

        # header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token")]

        # url =  "https://prices.azure.com/api/retail/prices?$filter=serviceName%20eq%20%27Virtual%20Machines%27%20and%20armSkuName%20eq%20%27Standard_D2s_v3%27%20and%20location%20eq%20%27AU%20East%27"
        # scope = "#{Map.get(azure_keys, "sub_id")}/resourceGroups/#{Map.get(azure_keys, "resource_group")}"
        # response = HTTPoison.get! url, header, []
        # body = Poison.Parser.parse!(response.body)

        # #Extract spot vms
        # spot_vms = Enum.filter(body["Items"], fn x ->
        #     if String.contains?(Map.get(x, "skuName"), "Spot") do
        #       x
        #     end
        # end)

        # IO.inspect(spot_vms)



        # #Iterate through our vms
        # Enum.each(vms, fn (vm) ->
        #     if String.contains?()
        # end)
    end

    # START AZURE MACHINES

    def start_azure_machine(name, azure_keys) do

        # Construct Header
        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token")]

        # Call Start Endpoint
        HTTPoison.post! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/resourceGroups/#{Map.get(azure_keys, "resource_group")}/providers/Microsoft.Compute/virtualMachines/#{name}/start?api-version=2022-08-01", [], header

        # IO.inspect(response)
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
        url = "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01"
        response = HTTPoison.post! url, Poison.encode!(body), header, options

        # Return decoded body
        Poison.decode! response.body
        # "https://management.azure.com/#{scope}/providers/Microsoft.CostManagement/query?api-version=2021-10-01"
    end

    def get_SKU(azure_keys) do

        header = ['Authorization': "Bearer " <> Map.get(azure_keys, "token"), 'content-type': "application/json"]

        response = HTTPoison.get! "https://management.azure.com/subscriptions/#{Map.get(azure_keys, "sub_id")}/providers/Microsoft.CognitiveServices/skus?api-version=2021-10-01", header, []

        body = Poison.decode!(response.body)

        IO.inspect(body)

        storage_sku = Enum.filter(body["value"], fn (x) ->
            if String.contains?(x["name"], "20_04-lts-gen2") do
              x
            end
        end)

        IO.inspect(storage_sku)



    end
end
