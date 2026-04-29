import logging
from typing import Optional
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.core.exceptions import AzureError

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

class VMScaleSetManager:
    """
    Manage Azure Virtual Machine Scale Sets using the Azure SDK.
    """

    def __init__(self, subscription_id: str):
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def scale_vmss(self, resource_group: str, vmss_name: str, new_capacity: int) -> bool:
        """
        Scale a VM Scale Set to a new instance count.

        Args:
            resource_group (str): Resource group name.
            vmss_name (str): VMSS name.
            new_capacity (int): Desired instance count.

        Returns:
            bool: True if scaling succeeded, False otherwise.
        """

        logging.info(f"Scaling VMSS '{vmss_name}' in '{resource_group}' to {new_capacity} instances.")

        try:
            vmss = self.client.virtual_machine_scale_sets.get(resource_group, vmss_name)
            vmss.sku.capacity = new_capacity

            poller = self.client.virtual_machine_scale_sets.begin_create_or_update(
                resource_group,
                vmss_name,
                vmss
            )

            poller.result()  # Wait for completion
            logging.info(f"VMSS '{vmss_name}' scaled successfully to {new_capacity} instances.")
            return True

        except AzureError as e:
            logging.error(f"Azure error while scaling VMSS: {e}")
            return False
        except Exception as e:
            logging.error(f"Unexpected error: {e}")
            return False


if __name__ == "__main__":
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"
    vmss_name = "your_vmss_name"

    manager = VMScaleSetManager(subscription_id)
    manager.scale_vmss(resource_group, vmss_name, new_capacity=5)
