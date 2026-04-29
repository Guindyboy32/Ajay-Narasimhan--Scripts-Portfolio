import logging
from typing import Optional

import boto3
from botocore.exceptions import ClientError, BotoCoreError


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


class EC2InstanceManager:
    """
    Manage AWS EC2 instance lifecycle operations using Boto3.

    Provides safe, predictable start/stop operations with structured logging,
    guardrails, and clean exception handling.
    """

    def __init__(self, profile_name: Optional[str] = None, region: Optional[str] = None):
        """
        Initialize the EC2 client using AWS's credential chain.

        Args:
            profile_name (Optional[str]): Optional AWS CLI profile.
            region (Optional[str]): Optional AWS region override.
        """
        try:
            session = boto3.Session(profile_name=profile_name, region_name=region)
            self.ec2 = session.client("ec2")
        except Exception as e:
            logging.error(f"Failed to initialize AWS session: {e}")
            raise

    def _get_instance_state(self, instance_id: str) -> Optional[str]:
        """
        Retrieve the current state of an EC2 instance.

        Args:
            instance_id (str): EC2 instance ID.

        Returns:
            Optional[str]: Instance state (e.g., 'running', 'stopped') or None.
        """
        try:
            response = self.ec2.describe_instances(InstanceIds=[instance_id])
            state = response["Reservations"][0]["Instances"][0]["State"]["Name"]
            return state
        except (ClientError, BotoCoreError) as e:
            logging.error(f"Failed to retrieve instance state for {instance_id}: {e}")
            return None

    def start_instance(self, instance_id: str, dry_run: bool = False) -> bool:
        """
        Start an EC2 instance safely.

        Args:
            instance_id (str): EC2 instance ID.
            dry_run (bool): If True, logs the action without executing.

        Returns:
            bool: True if successful, False otherwise.
        """
        state = self._get_instance_state(instance_id)
        logging.info(f"Current state of {instance_id}: {state}")

        if state == "running":
            logging.info(f"Instance {instance_id} is already running. No action taken.")
            return True

        if dry_run:
            logging.info(f"[Dry Run] Instance {instance_id} would be started.")
            return True

        logging.info(f"Starting instance {instance_id}")

        try:
            response = self.ec2.start_instances(InstanceIds=[instance_id])
            logging.info(f"Start initiated: {response}")
            return True
        except (ClientError, BotoCoreError) as e:
            logging.error(f"Failed to start instance {instance_id}: {e}")
            return False

    def stop_instance(self, instance_id: str, dry_run: bool = False) -> bool:
        """
        Stop (shut down) an EC2 instance safely.

        Args:
            instance_id (str): EC2 instance ID.
            dry_run (bool): If True, logs the action without executing.

        Returns:
            bool: True if successful, False otherwise.
        """
        state = self._get_instance_state(instance_id)
        logging.info(f"Current state of {instance_id}: {state}")

        if state in ("stopped", "stopping"):
            logging.info(f"Instance {instance_id} is already stopped. No action taken.")
            return True

        if dry_run:
            logging.info(f"[Dry Run] Instance {instance_id} would be stopped.")
            return True

        logging.info(f"Stopping instance {instance_id}")

        try:
            response = self.ec2.stop_instances(InstanceIds=[instance_id])
            logging.info(f"Stop initiated: {response}")
            return True
        except (ClientError, BotoCoreError) as e:
            logging.error(f"Failed to stop instance {instance_id}: {e}")
            return False


if __name__ == "__main__":
    instance_id = "i-0abcd1234efgh5678"

    manager = EC2InstanceManager()
    manager.start_instance(instance_id)
    manager.stop_instance(instance_id)
