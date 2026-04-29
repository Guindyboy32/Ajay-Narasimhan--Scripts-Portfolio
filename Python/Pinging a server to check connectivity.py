import platform
import subprocess
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def ping_host(hostname: str) -> bool:
    """
    Ping a host and return True if reachable, False otherwise.

    Args:
        hostname (str): Hostname or IP address to ping.

    Returns:
        bool: True if host responds, False otherwise.
    """

    system = platform.system()

    # Windows uses -n, Linux/macOS use -c
    count_flag = "-n" if system == "Windows" else "-c"

    try:
        result = subprocess.run(
            ["ping", count_flag, "1", hostname],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return result.returncode == 0

    except Exception as e:
        logging.error(f"Ping failed due to error: {e}")
        return False


if __name__ == "__main__":
    hostname = "google.com"
    if ping_host(hostname):
        logging.info(f"{hostname} is up.")
    else:
        logging.warning(f"{hostname} is down.")
