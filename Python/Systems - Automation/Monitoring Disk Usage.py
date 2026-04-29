import shutil
import platform
import logging
from typing import Dict

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def get_disk_usage() -> Dict[str, float]:
    """
    Retrieve disk usage statistics for the system's primary drive.

    Returns:
        dict: A dictionary containing total, used, and free space in GB.
    """

    # Determine correct root path
    root = "C:\\" if platform.system() == "Windows" else "/"

    try:
        total, used, free = shutil.disk_usage(root)
    except Exception as e:
        logging.error(f"Failed to retrieve disk usage: {e}")
        raise

    return {
        "Total_GB": round(total / (2**30), 2),
        "Used_GB": round(used / (2**30), 2),
        "Free_GB": round(free / (2**30), 2),
    }

def print_disk_usage():
    """Pretty‑print disk usage information."""
    usage = get_disk_usage()
    for key, value in usage.items():
        logging.info(f"{key}: {value} GB")

if __name__ == "__main__":
    print_disk_usage()
