import logging
from typing import Optional
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.core.exceptions import AzureError

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

class AzureVMManager:
    """
    Manage Azure Virtual Machines using the Azure SDK.
    """

    def __init__(self, subscription_id: str):
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def start_vm(self, resource_group: str, vm_name: str) -> bool:
        """
        Start an Azure VM.
        """
        logging.info(f"Starting VM: {vm_name} in {resource_group}")

        try:
            poller = self.client.virtual_machines.begin_start(resource_group, vm_name)
            poller.result()  # Wait for completion
            logging.info(f"VM '{vm_name}' started successfully.")
            return True

        except AzureError as e:
            logging.error(f"Failed to start VM '{vm_name}': {e}")
            return False

    def stop_vm(self, resource_group: str, vm_name: str) -> bool:
        """
        Stop (deallocate) an Azure VM.
        """
        logging.info(f"Stopping VM: {vm_name} in {resource_group}")

        try:
            poller = self.client.virtual_machines.begin_deallocate(resource_group, vm_name)
            poller.result()
            logging.info(f"VM '{vm_name}' stopped successfully.")
            return True

        except AzureError as e:
            logging.error(f"Failed to stop VM '{vm_name}': {e}")
            return False


if __name__ == "__main__":
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"
    vm_name = "your_vm_name"

    manager = AzureVMManager(subscription_id)
    manager.start_vm(resource_group, vm_name)
    manager.stop_vm(resource_group, vm_name)
