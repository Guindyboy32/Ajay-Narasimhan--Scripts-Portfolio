import logging
from typing import Dict
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.core.exceptions import AzureError

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

class AzureVMManager:
    """
    Create and manage Azure Virtual Machines using the Azure SDK.
    """

    def __init__(self, subscription_id: str):
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def create_vm(self, resource_group: str, vm_name: str, vm_parameters: Dict) -> bool:
        """
        Create or update a virtual machine.

        Args:
            resource_group (str): Resource group name.
            vm_name (str): Name of the VM.
            vm_parameters (dict): VM configuration dictionary.

        Returns:
            bool: True if creation succeeded, False otherwise.
        """

        logging.info(f"Starting VM creation: {vm_name}")

        try:
            poller = self.client.virtual_machines.begin_create_or_update(
                resource_group,
                vm_name,
                vm_parameters
            )
            poller.result()  # Wait for completion

            logging.info(f"VM '{vm_name}' created successfully.")
            return True

        except AzureError as e:
            logging.error(f"Azure error while creating VM: {e}")
            return False
        except Exception as e:
            logging.error(f"Unexpected error: {e}")
            return False


if __name__ == "__main__":
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"
    vm_name = "your_vm_name"
    location = "your_location"
    nic_name = "your_nic_name"

    # Build NIC resource ID safely
    nic_id = (
        f"/subscriptions/{subscription_id}/resourceGroups/{resource_group}"
        f"/providers/Microsoft.Network/networkInterfaces/{nic_name}"
    )

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
            "admin_password": "your_password"  # Replace with Key Vault or env var in real use
        },
        "network_profile": {
            "network_interfaces": [
                {"id": nic_id}
            ]
        }
    }

    manager = AzureVMManager(subscription_id)
    manager.create_vm(resource_group, vm_name, vm_parameters)
