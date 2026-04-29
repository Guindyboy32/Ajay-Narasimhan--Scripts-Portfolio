import platform
import psutil
import os

def get_system_info() -> dict:
    """
    Collect system information including OS details, CPU specs,
    memory, and disk capacity.

    Returns:
        dict: A dictionary containing system information.
    """

    # Determine correct root path for disk usage
    root_path = "C:\\" if platform.system() == "Windows" else "/"

    try:
        disk = psutil.disk_usage(root_path)
    except Exception:
        disk = None

    info = {
        "System": platform.system(),
        "Node Name": platform.node(),
        "Release": platform.release(),
        "Version": platform.version(),
        "Machine": platform.machine(),
        "Processor": platform.processor(),
        "CPU Cores": psutil.cpu_count(logical=False),
        "Logical CPUs": psutil.cpu_count(logical=True),
        "Memory (GB)": round(psutil.virtual_memory().total / (1024 ** 3), 2),
        "Disk Space (GB)": round(disk.total / (1024 ** 3), 2) if disk else "Unavailable"
    }

    return info


def print_system_info():
    """Pretty‑print system information."""
    info = get_system_info()
    for key, value in info.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    print_system_info()
