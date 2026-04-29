import subprocess
import logging
from typing import List

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def install_package(package: str) -> bool:
    """
    Install a Python package using pip.

    Args:
        package (str): The package name to install.

    Returns:
        bool: True if installation succeeded, False otherwise.
    """
    try:
        subprocess.check_call(["pip", "install", package])
        logging.info(f"Installed: {package}")
        return True
    except subprocess.CalledProcessError:
        logging.error(f"Failed to install: {package}")
        return False

def install_packages(packages: List[str]):
    """
    Install a list of Python packages.
    """
    for pkg in packages:
        install_package(pkg)

if __name__ == "__main__":
    software_list = ["software1", "software2", "software3"]
    install_packages(software_list)
