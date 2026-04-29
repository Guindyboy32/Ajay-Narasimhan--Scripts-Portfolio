import psutil
import logging
from typing import Dict

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def get_system_usage() -> Dict[str, float]:
    """
    Retrieve CPU and memory usage statistics.

    Returns:
        dict: A dictionary containing CPU usage (%) and memory usage (%).
    """
    try:
        cpu = psutil.cpu_percent(interval=1)
        mem = psutil.virtual_memory().percent
        return {"cpu_usage": cpu, "memory_usage": mem}
    except Exception as e:
        logging.error(f"Failed to retrieve system usage: {e}")
        raise

def print_system_usage():
    """Pretty‑print system usage metrics."""
    usage = get_system_usage()
    logging.info(f"CPU Usage: {usage['cpu_usage']}%")
    logging.info(f"Memory Usage: {usage['memory_usage']}%")

if __name__ == "__main__":
    print_system_usage()
