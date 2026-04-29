import subprocess
import shlex

def uninstall_software(software_name: str):
    """
    Safely attempts to uninstall software using PowerShell's Get-Package.
    Avoids Win32_Product due to MSI reconfiguration risks.

    Parameters:
        software_name (str): Name or partial name of the software to uninstall.
    """

    print(f"Searching for installed packages matching: {software_name}")

    # Use Get-Package instead of Win32_Product
    ps_command = f"""
    $pkg = Get-Package | Where-Object {{ $_.Name -like '*{software_name}*' }};
    if ($pkg) {{
        Write-Output "Found: $($pkg.Name)";
        $pkg | Uninstall-Package -Force -ErrorAction Stop;
    }} else {{
        Write-Output "No matching software found.";
    }}
    """

    try:
        result = subprocess.run(
            ["powershell", "-Command", ps_command],
            capture_output=True,
            text=True,
            check=True
        )
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("Error during uninstall:")
        print(e.stderr)

if __name__ == "__main__":
    uninstall_software("ExampleSoftware")
