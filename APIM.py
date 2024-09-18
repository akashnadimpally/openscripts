import csv
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import SubscriptionClient, ResourceManagementClient
from azure.mgmt.apimanagement import ApiManagementClient

# Set up authentication
credential = DefaultAzureCredential()

# Initialize Subscription Client
subscription_client = SubscriptionClient(credential)

# Output CSV file
output_file = 'apim_apis.csv'

# Open the CSV file for writing
with open(output_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    # Write the header row
    writer.writerow(['Resource Group', 'Subscription', 'APIM Name', 'API ID', 'API Name'])

    # Loop through all subscriptions
    for subscription in subscription_client.subscriptions.list():
        subscription_id = subscription.subscription_id
        print(f"Checking subscription: {subscription_id}")

        # Initialize Resource Management Client and APIM Client
        resource_client = ResourceManagementClient(credential, subscription_id)
        apim_client = ApiManagementClient(credential, subscription_id)

        # Loop through all resource groups
        for rg in resource_client.resource_groups.list():
            resource_group_name = rg.name

            # Filter only API Management services in the resource group
            apim_services = resource_client.resources.list_by_resource_group(resource_group_name, filter="resourceType eq 'Microsoft.ApiManagement/service'")
            
            for apim_service in apim_services:
                service_name = apim_service.name
                print(f"Checking APIM service: {service_name}")

                # List all APIs in the APIM service
                for api in apim_client.api.list_by_service(resource_group_name, service_name):
                    if api.api_type == "openapi":  # Filter for OpenAPI type
                        print(f"Found OpenAPI '{api.name}' in APIM '{service_name}'")
                        # Write the details to the CSV file
                        writer.writerow([resource_group_name, subscription_id, service_name, api.name, api.display_name])

print(f"API details written to {output_file}")
