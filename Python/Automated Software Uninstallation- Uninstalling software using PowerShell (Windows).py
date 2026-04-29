import subprocess
import logging
import platform
from typing import Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def uninstall_software(software_name: str) -> bool:
    """
    Uninstall software on Windows using PowerShell's Get-Package and Uninstall-Package.

    Args:
        software_name (str): Name or partial name of the software to uninstall.

    Returns:
        bool: True if uninstall succeeded, False otherwise.
    """

    if platform.system() != "Windows":
        logging.error("This function only works on Windows.")
        return False

    if not software_name or not isinstance(software_name, str):
        logging.error("Invalid software name.")
        return False

    logging.info(f"Searching for installed packages matching: {software_name}")

    # Escape single quotes for PowerShell safety
    safe_name = software_name.replace("'", "''")

    ps_command = f"""
    $pkg = Get-Package | Where-Object {{ $_.Name -like '*{safe_name}*' }};
    if ($pkg) {{
        Write-Output "Found: $($pkg.Name)";
        try {{
            $pkg | Uninstall-Package -Force -ErrorAction Stop;
            Write-Output "Uninstall completed.";
        }} catch {{
            Write-Output "Uninstall failed: $($_.Exception.Message)";
            exit 1
        }}
    }} else {{
        Write-Output "No matching software found.";
        exit 2
    }}
    """

    try:
        result = subprocess.run(
            ["powershell", "-NoProfile", "-Command", ps_command],
            capture_output=True,
            text=True,
            check=False
        )

        logging.info(result.stdout.strip())

        if result.returncode == 0:
            return True
        else:
            logging.error(result.stderr.strip())
            return False

    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return False


if __name__ == "__main__":
    uninstall_software("ExampleSoftware")
