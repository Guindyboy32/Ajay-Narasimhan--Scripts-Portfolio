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

    Provides safe, predictable VM lifecycle operations with structured logging,
    guardrails, and clean exception handling.
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
            Optional[str]: Power state string (e.g., 'running', 'stopped') or None.
        """
        try:
            instance_view = self.client.virtual_machines.instance_view(
                resource_group,
                vm_name
            )
            for status in instance_view.statuses:
                if status.code.startswith("PowerState/"):
                    return status.code.split("/", 1)[1]
        except AzureError:
            return None

        return None

    def start_vm(self, resource_group: str, vm_name: str, dry_run: bool = False) -> bool:
        """
        Start an Azure VM safely.

        Args:
            resource_group (str): Resource group name.
            vm_name (str): VM name.
            dry_run (bool): If True, logs the action without executing.

        Returns:
            bool: True if successful, False otherwise.
        """

        power_state = self._get_power_state(resource_group, vm_name)
        logging.info(f"Current power state of '{vm_name}': {power_state}")

        if power_state == "running":
            logging.info(f"VM '{vm_name}' is already running. No action taken.")
            return True

        if dry_run:
            logging.info(f"[Dry Run] VM '{vm_name}' would be started.")
            return True

        logging.info(f"Starting VM '{vm_name}' in '{resource_group}'")

        try:
            poller = self.client.virtual_machines.begin_start(resource_group, vm_name)
            poller.result()
            logging.info(f"VM '{vm_name}' started successfully.")
            return True

        except AzureError as e:
            logging.error(f"Failed to start VM '{vm_name}': {e}")
            return False

    def stop_vm(self, resource_group: str, vm_name: str, dry_run: bool = False) -> bool:
        """
        Stop (deallocate) an Azure VM safely.

        Args:
            resource_group (str): Resource group name.
            vm_name (str): VM name.
            dry_run (bool): If True, logs the action without executing.

        Returns:
            bool: True if successful, False otherwise.
        """

        power_state = self._get_power_state(resource_group, vm_name)
        logging.info(f"Current power state of '{vm_name}': {power_state}")

        if power_state in ("stopped", "deallocated"):
            logging.info(f"VM '{vm_name}' is already stopped. No action taken.")
            return True

        if dry_run:
            logging.info(f"[Dry Run] VM '{vm_name}' would be stopped.")
            return True

        logging.info(f"Stopping VM '{vm_name}' in '{resource_group}'")

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
