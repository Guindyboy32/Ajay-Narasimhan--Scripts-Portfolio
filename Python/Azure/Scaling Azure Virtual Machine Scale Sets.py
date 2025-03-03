Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> from azure.identity import DefaultAzureCredential
... from azure.mgmt.compute import ComputeManagementClient
... 
... subscription_id = 'your_subscription_id'
... resource_group = 'your_resource_group'
... vmss_name = 'your_vmss_name'
... 
... credential = DefaultAzureCredential()
... compute_client = ComputeManagementClient(credential, subscription_id)
... 
... vmss = compute_client.virtual_machine_scale_sets.get(resource_group, vmss_name)
... vmss.sku.capacity = 5  # Scale to 5 instances
... 
... async_vmss_update = compute_client.virtual_machine_scale_sets.begin_create_or_update(resource_group, vmss_name, vmss)
... vmss_result = async_vmss_update.result()
... print(f"VMSS {vmss_name} scaled successfully.")
... 
... 
