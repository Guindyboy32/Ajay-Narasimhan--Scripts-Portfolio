Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> from azure.identity import DefaultAzureCredential
... from azure.mgmt.compute import ComputeManagementClient
... 
... subscription_id = 'your_subscription_id'
... resource_group = 'your_resource_group'
... vm_name = 'your_vm_name'
... 
... credential = DefaultAzureCredential()
... compute_client = ComputeManagementClient(credential, subscription_id)
... 
... def start_vm(resource_group, vm_name):
...     async_vm_start = compute_client.virtual_machines.begin_start(resource_group, vm_name)
...     async_vm_start.result()
...     print(f"VM {vm_name} started successfully.")
... 
... def stop_vm(resource_group, vm_name):
...     async_vm_stop = compute_client.virtual_machines.begin_deallocate(resource_group, vm_name)
...     async_vm_stop.result()
...     print(f"VM {vm_name} stopped successfully.")
... 
... if __name__ == "__main__":
...     start_vm(resource_group, vm_name)
...     stop_vm(resource_group, vm_name)
... 
... 
... 
