import subprocess
import logging
from typing import Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def connect_rdp(host: str, user: Optional[str] = None) -> None:
    """
    Launch a Remote Desktop session using mstsc.

    Args:
        host (str): Hostname or IP address of the remote machine.
        user (str | None): Optional username for the RDP session.
    """
    if not host:
        logging.error("Host cannot be empty.")
        return

    command = ["mstsc", "/v:" + host]

    if user:
        command.append("/u:" + user)

    logging.info(f"Launching RDP session to {host} as {user or 'current user'}")

    try:
        subprocess.run(command, check=True)
    except FileNotFoundError:
        logging.error("mstsc.exe not found. Ensure Remote Desktop is installed.")
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to start RDP session: {e}")

if __name__ == "__main__":
    connect_rdp("remote_host", "username")
