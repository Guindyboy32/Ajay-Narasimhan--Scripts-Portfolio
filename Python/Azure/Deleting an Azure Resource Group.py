import logging
from typing import Optional

from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.core.exceptions import AzureError


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


class ResourceGroupManager:
    """
    Manage Azure Resource Groups safely using the Azure SDK.

    This class provides guardrails around destructive operations,
    structured logging, and clean exception handling.
    """

    def __init__(self, subscription_id: str):
        if not subscription_id:
            raise ValueError("Subscription ID cannot be empty.")

        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ResourceManagementClient(self.credential, subscription_id)

    def resource_group_exists(self, resource_group: str) -> bool:
        """
        Check whether a resource group exists.

        Args:
            resource_group (str): Name of the resource group.

        Returns:
            bool: True if it exists, False otherwise.
        """
        try:
            self.client.resource_groups.get(resource_group)
            return True
        except AzureError:
            return False

    def delete_resource_group(
        self,
        resource_group: str,
        require_confirmation: bool = True
    ) -> bool:
        """
        Delete a resource group and all resources inside it.

        Args:
            resource_group (str): Name of the resource group to delete.
            require_confirmation (bool): If True, requires user confirmation.

        Returns:
            bool: True if deletion succeeded, False otherwise.
        """

        if not resource_group:
            logging.error("Resource group name cannot be empty.")
            return False

        if not self.resource_group_exists(resource_group):
            logging.error(f"Resource group '{resource_group}' does not exist.")
            return False

        if require_confirmation:
            logging.warning(
                f"Deletion requested for resource group '{resource_group}'. "
                "This operation is irreversible."
            )
            user_input = input("Type 'DELETE' to confirm: ").strip()
            if user_input != "DELETE":
                logging.info("Deletion cancelled by user.")
                return False

        logging.info(f"Deleting resource group: {resource_group}")

        try:
            poller = self.client.resource_groups.begin_delete(resource_group)
            poller.result()  # Wait for completion

            logging.info(f"Resource group '{resource_group}' deleted successfully.")
            return True

        except AzureError as e:
            logging.error(f"Azure error while deleting resource group '{resource_group}': {e}")
            return False

        except Exception as e:
            logging.error(f"Unexpected error during deletion: {e}")
            return False


if __name__ == "__main__":
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"

    manager = ResourceGroupManager(subscription_id)
    manager.delete_resource_group(resource_group)
