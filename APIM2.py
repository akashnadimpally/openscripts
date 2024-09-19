import pandas as pd
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.apimanagement import ApiManagementClient
from azure.core.exceptions import HttpResponseError

# Set up authentication
credential = DefaultAzureCredential()

# List of subscription IDs to loop through
subscription_ids = [
    "your-subscription-id-1",
    "your-subscription-id-2",
    # Add more subscription IDs as needed
]

# Initialize an empty DataFrame
df = pd.DataFrame(columns=['Resource Group', 'Subscription', 'APIM Name', 'API ID', 'API Name'])

# Loop through each subscription ID
for subscription_id in subscription_ids:
    try:
        print(f"Checking subscription: {subscription_id}")
        # Initialize Resource Management Client and APIM Client
        resource_client = ResourceManagementClient(credential, subscription_id)
        apim_client = ApiManagementClient(credential, subscription_id)

        # Loop through all resource groups
        for rg in resource_client.resource_groups.list():
            resource_group_name = rg.name

            try:
                # Filter only API Management services in the resource group
                apim_services = resource_client.resources.list_by_resource_group(resource_group_name, filter="resourceType eq 'Microsoft.ApiManagement/service'")
                
                for apim_service in apim_services:
                    service_name = apim_service.name
                    print(f"Checking APIM service: {service_name}")

                    # List all APIs in the APIM service
                    for api in apim_client.api.list_by_service(resource_group_name, service_name):
                        if api.api_type == "openapi":  # Filter for OpenAPI type
                            print(f"Found OpenAPI '{api.name}' in APIM '{service_name}'")
                            # Append the data to the DataFrame
                            df = df.append({
                                'Resource Group': resource_group_name,
                                'Subscription': subscription_id,
                                'APIM Name': service_name,
                                'API ID': api.name,
                                'API Name': api.display_name
                            }, ignore_index=True)

            except HttpResponseError as e:
                print(f"An error occurred while processing resource group {resource_group_name}: {str(e)}")

    except HttpResponseError as e:
        print(f"An error occurred in subscription {subscription_id}: {str(e)}")

# Output to CSV
df.to_csv('apim_apis.csv', index=False)

print(f"API details written to 'apim_apis.csv'")



# import pandas as pd
# from azure.identity import DefaultAzureCredential
# from azure.mgmt.resource import ResourceManagementClient
# from azure.mgmt.apimanagement import ApiManagementClient
# from azure.core.exceptions import HttpResponseError

# # Set up authentication
# credential = DefaultAzureCredential()

# # Specify your subscription ID
# subscription_id = "your-subscription-id"

# # Initialize an empty DataFrame
# df = pd.DataFrame(columns=['Resource Group', 'Subscription', 'APIM Name', 'API ID', 'API Name'])

# try:
#     # Initialize Resource Management Client and APIM Client
#     resource_client = ResourceManagementClient(credential, subscription_id)
#     apim_client = ApiManagementClient(credential, subscription_id)

#     # Loop through all resource groups
#     for rg in resource_client.resource_groups.list():
#         resource_group_name = rg.name

#         try:
#             # Filter only API Management services in the resource group
#             apim_services = resource_client.resources.list_by_resource_group(resource_group_name, filter="resourceType eq 'Microsoft.ApiManagement/service'")
            
#             for apim_service in apim_services:
#                 service_name = apim_service.name
#                 print(f"Checking APIM service: {service_name}")

#                 # List all APIs in the APIM service
#                 for api in apim_client.api.list_by_service(resource_group_name, service_name):
#                     if api.api_type == "openapi":  # Filter for OpenAPI type
#                         print(f"Found OpenAPI '{api.name}' in APIM '{service_name}'")
#                         # Append the data to the DataFrame
#                         df = df.append({
#                             'Resource Group': resource_group_name,
#                             'Subscription': subscription_id,
#                             'APIM Name': service_name,
#                             'API ID': api.name,
#                             'API Name': api.display_name
#                         }, ignore_index=True)

#         except HttpResponseError as e:
#             print(f"An error occurred while processing resource group {resource_group_name}: {str(e)}")

# except HttpResponseError as e:
#     print(f"An error occurred in subscription {subscription_id}: {str(e)}")

# # Output to CSV
# df.to_csv('apim_apis.csv', index=False)

# print(f"API details written to 'apim_apis.csv'")



# # import csv
# # from azure.identity import DefaultAzureCredential
# # from azure.mgmt.resource import ResourceManagementClient
# # from azure.mgmt.apimanagement import ApiManagementClient
# # from azure.core.exceptions import HttpResponseError

# # # Set up authentication
# # credential = DefaultAzureCredential()

# # # Specify your subscription ID
# # subscription_id = "your-subscription-id"

# # # Output CSV file
# # output_file = 'apim_apis.csv'

# # # Open the CSV file for writing
# # with open(output_file, mode='w', newline='') as file:
# #     writer = csv.writer(file)
# #     # Write the header row
# #     writer.writerow(['Resource Group', 'Subscription', 'APIM Name', 'API ID', 'API Name'])

# #     try:
# #         # Initialize Resource Management Client and APIM Client
# #         resource_client = ResourceManagementClient(credential, subscription_id)
# #         apim_client = ApiManagementClient(credential, subscription_id)

# #         # Loop through all resource groups
# #         for rg in resource_client.resource_groups.list():
# #             resource_group_name = rg.name

# #             try:
# #                 # Filter only API Management services in the resource group
# #                 apim_services = resource_client.resources.list_by_resource_group(resource_group_name, filter="resourceType eq 'Microsoft.ApiManagement/service'")
                
# #                 for apim_service in apim_services:
# #                     service_name = apim_service.name
# #                     print(f"Checking APIM service: {service_name}")

# #                     # List all APIs in the APIM service
# #                     for api in apim_client.api.list_by_service(resource_group_name, service_name):
# #                         if api.api_type == "openapi":  # Filter for OpenAPI type
# #                             print(f"Found OpenAPI '{api.name}' in APIM '{service_name}'")
# #                             # Write the details to the CSV file
# #                             writer.writerow([resource_group_name, subscription_id, service_name, api.name, api.display_name])

# #             except HttpResponseError as e:
# #                 print(f"An error occurred while processing resource group {resource_group_name}: {str(e)}")

# #     except HttpResponseError as e:
# #         print(f"An error occurred in subscription {subscription_id}: {str(e)}")

# # print(f"API details written to {output_file}")
