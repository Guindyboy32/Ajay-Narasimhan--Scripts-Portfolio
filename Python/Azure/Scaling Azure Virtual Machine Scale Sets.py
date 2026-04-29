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

    Provides guardrails, structured logging, and clean exception handling
    for safe and predictable VMSS scaling operations.
    """

    def __init__(self, subscription_id: str):
        if not subscription_id:
            raise ValueError("Subscription ID cannot be empty.")

        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ComputeManagementClient(self.credential, subscription_id)

    def get_current_capacity(self, resource_group: str, vmss_name: str) -> Optional[int]:
        """
        Retrieve the current instance count of a VM Scale Set.

        Args:
            resource_group (str): Resource group name.
            vmss_name (str): VMSS name.

        Returns:
            Optional[int]: Current capacity or None if unavailable.
        """
        try:
            vmss = self.client.virtual_machine_scale_sets.get(resource_group, vmss_name)
            return vmss.sku.capacity
        except AzureError:
            return None

    def scale_vmss(
        self,
        resource_group: str,
        vmss_name: str,
        new_capacity: int,
        dry_run: bool = False
    ) -> bool:
        """
        Scale a VM Scale Set to a new instance count.

        Args:
            resource_group (str): Resource group name.
            vmss_name (str): VMSS name.
            new_capacity (int): Desired instance count.
            dry_run (bool): If True, logs the action without applying changes.

        Returns:
            bool: True if scaling succeeded, False otherwise.
        """

        if new_capacity < 0:
            logging.error("New capacity cannot be negative.")
            return False

        logging.info(
            f"Requested scale operation for VMSS '{vmss_name}' "
            f"in '{resource_group}' to {new_capacity} instances."
        )

        current_capacity = self.get_current_capacity(resource_group, vmss_name)

        if current_capacity is None:
            logging.error("Unable to retrieve current VMSS capacity.")
            return False

        logging.info(f"Current capacity: {current_capacity}")

        if current_capacity == new_capacity:
            logging.info("Requested capacity matches current capacity. No action taken.")
            return True

        if dry_run:
            logging.info(
                f"[Dry Run] VMSS '{vmss_name}' would be scaled from "
                f"{current_capacity} → {new_capacity}."
            )
            return True

        try:
            vmss = self.client.virtual_machine_scale_sets.get(resource_group, vmss_name)
            vmss.sku.capacity = new_capacity

            poller = self.client.virtual_machine_scale_sets.begin_create_or_update(
                resource_group,
                vmss_name,
                vmss
            )

            poller.result()  # Wait for completion

            logging.info(
                f"VMSS '{vmss_name}' scaled successfully: "
                f"{current_capacity} → {new_capacity}."
            )
            return True

        except AzureError as e:
            logging.error(f"Azure error while scaling VMSS '{vmss_name}': {e}")
            return False

        except Exception as e:
            logging.error(f"Unexpected error during VMSS scaling: {e}")
            return False


if __name__ == "__main__":
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"
    vmss_name = "your_vmss_name"

    manager = VMScaleSetManager(subscription_id)
    manager.scale_vmss(resource_group, vmss_name, new_capacity=5)
