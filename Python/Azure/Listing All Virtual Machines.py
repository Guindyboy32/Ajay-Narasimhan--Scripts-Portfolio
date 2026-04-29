import logging
from typing import List
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.core.exceptions import AzureError

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

class AzureVMInventory:
    """
    Retrieve and display Azure Virtual Machine inventory.
    """

    def __init__(self, subscription_id: str):
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def list_all_vms(self) -> List[str]:
        """
        List all VMs in the subscription with basic metadata.

        Returns:
            List[str]: A list of VM names.
        """
        vm_names = []

        try:
            vms = self.client.virtual_machines.list_all()

            for vm in vms:
                vm_names.append(vm.name)
                logging.info(
                    f"VM Name: {vm.name}, "
                    f"Location: {vm.location}, "
                    f"Size: {vm.hardware_profile.vm_size}"
                )

        except AzureError as e:
            logging.error(f"Failed to list VMs: {e}")

        return vm_names


if __name__ == "__main__":
    subscription_id = "your_subscription_id"

    inventory = AzureVMInventory(subscription_id)
    inventory.list_all_vms()
