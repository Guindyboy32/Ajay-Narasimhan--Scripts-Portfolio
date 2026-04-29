import platform
import subprocess
import logging
import psutil
from typing import Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def check_cpu_usage(threshold: int) -> bool:
    """
    Check if CPU usage exceeds a given threshold.

    Args:
        threshold (int): CPU percentage threshold.

    Returns:
        bool: True if usage exceeds threshold, False otherwise.
    """
    usage = psutil.cpu_percent(interval=2)
    logging.info(f"Current CPU usage: {usage}%")
    return usage > threshold

def reboot_system():
    """
    Reboot the system safely depending on OS.
    """
    system = platform.system()

    try:
        if system == "Windows":
            logging.info("Rebooting Windows system...")
            subprocess.run(["shutdown", "/r", "/t", "5"], check=True)

        elif system == "Linux":
            logging.info("Rebooting Linux system...")
            subprocess.run(["sudo", "reboot"], check=True)

        else:
            logging.error(f"Unsupported OS: {system}")
            return

        logging.info("Reboot command issued successfully.")

    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to reboot system: {e}")

def main(threshold: int = 90):
    """
    Main logic for CPU monitoring and conditional reboot.
    """
    if check_cpu_usage(threshold):
        logging.warning(f"CPU usage exceeded {threshold}%. Rebooting system.")
        reboot_system()
    else:
        logging.info("CPU usage is within acceptable limits.")

if __name__ == "__main__":
    main(90)
