import logging
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
    """

    def __init__(self, subscription_id: str):
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.client = ResourceManagementClient(self.credential, subscription_id)

    def delete_resource_group(self, resource_group: str) -> bool:
        """
        Delete a resource group and all resources inside it.

        Args:
            resource_group (str): Name of the resource group to delete.

        Returns:
            bool: True if deletion succeeded, False otherwise.
        """

        logging.info(f"Attempting to delete resource group: {resource_group}")

        try:
            poller = self.client.resource_groups.begin_delete(resource_group)
            poller.result()  # Wait for completion
            logging.info(f"Resource group '{resource_group}' deleted successfully.")
            return True

        except AzureError as e:
            logging.error(f"Azure error while deleting resource group: {e}")
            return False
        except Exception as e:
            logging.error(f"Unexpected error: {e}")
            return False


if __name__ == "__main__":
    subscription_id = "your_subscription_id"
    resource_group = "your_resource_group"

    manager = ResourceGroupManager(subscription_id)
    manager.delete_resource_group(resource_group)
