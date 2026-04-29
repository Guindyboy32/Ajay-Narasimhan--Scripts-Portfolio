import logging
from typing import Dict, Optional

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

    This class encapsulates VM lifecycle operations and provides
    structured logging, exception handling, and identity‑aware authentication.
    """

    def __init__(self, subscription_id: str):
        if not subscription_id:
            raise ValueError("Subscription ID cannot be empty.")

        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def create_vm(
        self,
        resource_group: str,
        vm_name: str,
        vm_parameters: Dict
    ) -> bool:
        """
        Create or update a virtual machine.

        Args:
            resource_group (str): Resource group name.
            vm_name (str): Name of the VM.
            vm_parameters (dict): VM configuration dictionary.

        Returns:
            bool: True if creation succeeded, False otherwise.
        """

        if not resource_group or not vm_name:
            logging.error("Resource group and VM name must be provided.")
            return False

        logging.info(f"Starting VM creation: {vm_name} in {resource_group}")

        try:
            poller = self.client.virtual_machines.begin_create_or_update(
                resource_group,
                vm_name,
                vm_parameters
            )

            result = poller.result()  # Wait for completion
            logging.info(f"VM '{vm_name}' created successfully.")
            return True

        except AzureError as e:
            logging.error(f"Azure error while creating VM '{vm_name}': {e}")
            return False

        except Exception as e:
            logging.error(f"Unexpected error during VM creation: {e}")
            return False


def build_nic_id(subscription_id: str, resource_group: str, nic_name: str) -> str:
    """
    Build a fully qualified NIC resource ID.

    Args:
        subscription_id (str): Azure subscription ID.
        resource_group (str): Resource group name.
        nic_name (str): NIC resource name.

    Returns:
        str: Fully qualified NIC resource ID.
    """
    return (
        f"/subscriptions/{subscription_id}/resourceGroups/{resource_group}"
        f"/providers/Microsoft.Network/networkInterfaces/{nic_name}"
    )


if __name__ == "__main__":
    # User‑provided values (replace or load from environment/Key Vault)
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"
    vm_name = "your_vm_name"
    location = "your_location"
    nic_name = "your_nic_name"

    # Build NIC ID safely
    nic_id = build_nic_id(subscription_id, resource_group, nic_name)

    # VM configuration
    vm_parameters = {
        "location": location,
        "hardware_profile": {
            "vm_size": "Standard_DS1_v2"
        },
        "storage_profile": {
            "image_reference": {
                "publisher": "Canonical",
                "offer": "UbuntuServer",
                "sku": "18.04-LTS",
                "version": "latest"
            }
        },
        "os_profile": {
            "computer_name": vm_name,
            "admin_username": "your_username",
            "admin_password": "your_password"  # Replace with Key Vault or env vars
        },
        "network_profile": {
            "network_interfaces": [
                {"id": nic_id}
            ]
        }
    }

    manager = AzureVMManager(subscription_id)
    manager.create_vm(resource_group, vm_name, vm_parameters)
