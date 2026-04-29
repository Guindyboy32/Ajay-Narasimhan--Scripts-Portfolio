import platform
import subprocess
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def schedule_shutdown(minutes: int):
    """
    Schedule a system shutdown after a specified number of minutes.

    Supports:
        - Windows: shutdown /s /t <seconds>
        - Linux:   shutdown -h +<minutes>

    Args:
        minutes (int): Number of minutes before shutdown.
    """

    if minutes <= 0:
        raise ValueError("Minutes must be greater than zero.")

    system = platform.system()
    logging.info(f"Preparing to schedule shutdown on {system} in {minutes} minutes.")

    try:
        if system == "Windows":
            seconds = minutes * 60
            subprocess.run(["shutdown", "/s", "/t", str(seconds)], check=True)

        elif system == "Linux":
            subprocess.run(["sudo", "shutdown", "-h", f"+{minutes}"], check=True)

        else:
            logging.error(f"Unsupported OS: {system}")
            return

        logging.info("Shutdown scheduled successfully.")

    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to schedule shutdown: {e}")

if __name__ == "__main__":
    schedule_shutdown(30)
