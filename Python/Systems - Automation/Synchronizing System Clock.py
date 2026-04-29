import platform
import subprocess
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def synchronize_clock():
    """
    Synchronize the system clock using the appropriate method for the OS.

    Windows:
        Uses w32tm to resync with the configured NTP server.
    Linux:
        Uses timedatectl (preferred) or falls back to ntpdate if available.
    """

    system = platform.system()

    try:
        if system == "Windows":
            logging.info("Synchronizing clock on Windows...")
            subprocess.run(["w32tm", "/resync"], check=True)

        elif system == "Linux":
            logging.info("Synchronizing clock on Linux...")

            # Preferred: timedatectl
            try:
                subprocess.run(["timedatectl", "set-ntp", "true"], check=True)
            except Exception:
                logging.warning("timedatectl not available, falling back to ntpdate...")
                subprocess.run(["sudo", "ntpdate", "time.nist.gov"], check=True)

        else:
            logging.error(f"Unsupported OS: {system}")
            return

        logging.info("System clock synchronized successfully.")

    except subprocess.CalledProcessError as e:
        logging.error(f"Clock synchronization failed: {e}")


if __name__ == "__main__":
    synchronize_clock()
