Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> from azure.identity import DefaultAzureCredential
... from azure.mgmt.compute import ComputeManagementClient
... 
... subscription_id = 'your_subscription_id'
... resource_group = 'your_resource_group'
... vm_name = 'your_vm_name'
... location = 'your_location'
... 
... credential = DefaultAzureCredential()
... compute_client = ComputeManagementClient(credential, subscription_id)
... 
... vm_parameters = {
...     'location': location,
...     'hardware_profile': {
...         'vm_size': 'Standard_DS1_v2'
...     },
...     'storage_profile': {
...         'image_reference': {
...             'publisher': 'Canonical',
...             'offer': 'UbuntuServer',
...             'sku': '18.04-LTS',
...             'version': 'latest'
...         }
...     },
...     'os_profile': {
...         'computer_name': vm_name,
...         'admin_username': 'your_username',
...         'admin_password': 'your_password'
...     },
...     'network_profile': {
...         'network_interfaces': [{
...             'id': '/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.Network/networkInterfaces/{nic_name}'
...         }]
...     }
... }
... 
... async_vm_creation = compute_client.virtual_machines.begin_create_or_update(resource_group, vm_name, vm_parameters)
... vm_result = async_vm_creation.result()
... print(f"VM {vm_name} created successfully.")
... 
... 
... 
... 
