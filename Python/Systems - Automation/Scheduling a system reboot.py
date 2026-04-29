import subprocess
import logging
from typing import List, Dict

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def install_package(package: str) -> bool:
    """
    Install a Python package using pip.

    Args:
        package (str): The package name to install.

    Returns:
        bool: True if installation succeeded, False otherwise.
    """
    if not package or not isinstance(package, str):
        logging.error(f"Invalid package name: {package}")
        return False

    try:
        subprocess.check_call(["pip", "install", package])
        logging.info(f"Installed: {package}")
        return True
    except subprocess.CalledProcessError:
        logging.error(f"Failed to install: {package}")
        return False
    except FileNotFoundError:
        logging.error("pip not found. Ensure Python and pip are installed and in PATH.")
        return False


def install_packages(packages: List[str]) -> Dict[str, bool]:
    """
    Install a list of Python packages.

    Returns:
        dict: A dictionary mapping package names to success/failure.
    """
    results = {}
    for pkg in packages:
        results[pkg] = install_package(pkg)
    return results


if __name__ == "__main__":
    software_list = ["software1", "software2", "software3"]
    results = install_packages(software_list)

    logging.info("Installation summary:")
    for pkg, status in results.items():
        logging.info(f"{pkg}: {'Success' if status else 'Failed'}")
