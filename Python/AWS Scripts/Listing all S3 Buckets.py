import logging
from typing import List, Dict, Optional

import boto3
from botocore.exceptions import BotoCoreError, ClientError


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


class S3InventoryManager:
    """
    Retrieve and display AWS S3 bucket inventory using Boto3.

    This class provides structured logging, clean exception handling,
    and a predictable interface suitable for automation pipelines.
    """

    def __init__(self, profile_name: Optional[str] = None):
        """
        Initialize the S3 client using the default AWS credential chain.

        Args:
            profile_name (Optional[str]): Optional AWS CLI profile to use.
        """
        try:
            session = boto3.Session(profile_name=profile_name) if profile_name else boto3.Session()
            self.s3 = session.client("s3")
        except Exception as e:
            logging.error(f"Failed to initialize AWS session: {e}")
            raise

    def list_buckets(self) -> List[Dict]:
        """
        Retrieve all S3 buckets in the account.

        Returns:
            List[Dict]: A list of bucket metadata dictionaries.
        """
        try:
            response = self.s3.list_buckets()
            buckets = response.get("Buckets", [])

            bucket_list = [
                {"name": bucket["Name"], "creation_date": bucket["CreationDate"]}
                for bucket in buckets
            ]

            for bucket in bucket_list:
                logging.info(f"Bucket: {bucket['name']} | Created: {bucket['creation_date']}")

            return bucket_list

        except (ClientError, BotoCoreError) as e:
            logging.error(f"Failed to list S3 buckets: {e}")
            return []


if __name__ == "__main__":
    manager = S3InventoryManager()
    manager.list_buckets()
