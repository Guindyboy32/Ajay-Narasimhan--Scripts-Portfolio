import os
import shutil
import logging
from typing import List

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def clean_temp_directory(temp_dir: str, dry_run: bool = False) -> None:
    """
    Recursively delete files and directories inside a temporary directory.

    Args:
        temp_dir (str): Path to the temporary directory.
        dry_run (bool): If True, only logs what would be deleted.
    """
    if not os.path.exists(temp_dir):
        logging.error(f"Directory does not exist: {temp_dir}")
        return

    if not os.path.isdir(temp_dir):
        logging.error(f"Not a directory: {temp_dir}")
        return

    logging.info(f"Cleaning temporary directory: {temp_dir}")
    logging.info(f"Dry run mode: {'ON' if dry_run else 'OFF'}")

    for root, dirs, files in os.walk(temp_dir, topdown=False):
        # Delete files
        for file in files:
            file_path = os.path.join(root, file)
            if dry_run:
                logging.info(f"[DRY RUN] Would delete file: {file_path}")
            else:
                try:
                    os.remove(file_path)
                    logging.info(f"Deleted file: {file_path}")
                except Exception as e:
                    logging.error(f"Error deleting file {file_path}: {e}")

        # Delete directories
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            if dry_run:
                logging.info(f"[DRY RUN] Would delete directory: {dir_path}")
            else:
                try:
                    shutil.rmtree(dir_path)
                    logging.info(f"Deleted directory: {dir_path}")
                except Exception as e:
                    logging.error(f"Error deleting directory {dir_path}: {e}")

if __name__ == "__main__":
    temp_dir = "C:\\Windows\\Temp"  # Example for Windows
    clean_temp_directory(temp_dir, dry_run=True)
