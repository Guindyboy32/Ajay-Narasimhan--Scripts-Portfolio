import logging
from typing import List, Dict, Optional

from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.core.exceptions import AzureError


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


class AzureVMInventory:
    """
    Retrieve and display Azure Virtual Machine inventory with detailed metadata.

    This class provides structured logging, exception handling, and helper
    methods to retrieve VM instance state and configuration details.
    """

    def __init__(self, subscription_id: str):
        if not subscription_id:
            raise ValueError("Subscription ID cannot be empty.")

        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def _get_power_state(self, resource_group: str, vm_name: str) -> Optional[str]:
        """
        Retrieve the power state of a VM.

        Args:
            resource_group (str): Resource group name.
            vm_name (str): VM name.

        Returns:
            Optional[str]: Power state string or None if unavailable.
        """
        try:
            instance_view = self.client.virtual_machines.instance_view(
                resource_group,
                vm_name
            )
            statuses = instance_view.statuses

            for status in statuses:
                if status.code.startswith("PowerState/"):
                    return status.code.split("/", 1)[1]

        except AzureError:
            return None

        return None

    def list_all_vms(self) -> List[Dict]:
        """
        List all VMs in the subscription with detailed metadata.

        Returns:
            List[Dict]: A list of VM metadata dictionaries.
        """
        vm_inventory = []

        try:
            vms = self.client.virtual_machines.list_all()

            for vm in vms:
                vm_info = {
                    "name": vm.name,
                    "location": vm.location,
                    "size": vm.hardware_profile.vm_size,
                    "resource_group": vm.id.split("/")[4],
                    "os_type": vm.storage_profile.os_disk.os_type.value
                    if vm.storage_profile and vm.storage_profile.os_disk else "Unknown",
                    "tags": vm.tags or {},
                }

                # Retrieve power state
                power_state = self._get_power_state(vm_info["resource_group"], vm.name)
                vm_info["power_state"] = power_state or "Unknown"

                vm_inventory.append(vm_info)

                logging.info(
                    f"VM Name: {vm_info['name']}, "
                    f"Location: {vm_info['location']}, "
                    f"Size: {vm_info['size']}, "
                    f"OS: {vm_info['os_type']}, "
                    f"Power State: {vm_info['power_state']}, "
                    f"Tags: {vm_info['tags']}"
                )

        except AzureError as e:
            logging.error(f"Failed to list VMs: {e}")

        return vm_inventory


if __name__ == "__main__":
    subscription_id = "your_subscription_id"

    inventory = AzureVMInventory(subscription_id)
    inventory.list_all_vms()
