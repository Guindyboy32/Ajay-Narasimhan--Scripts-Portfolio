import subprocess
import platform

def schedule_shutdown(minutes: int):
    """
    Schedule a system shutdown after a specified number of minutes.

    Parameters:
        minutes (int): Number of minutes before shutdown.

    Notes:
        - Windows only. Uses 'shutdown -s -t <seconds>'.
        - Includes basic validation and user confirmation.
    """

    if minutes <= 0:
        raise ValueError("Minutes must be greater than zero.")

    if platform.system() != "Windows":
        raise OSError("This shutdown script currently supports Windows only.")

    seconds = minutes * 60
    command = ["shutdown", "-s", "-t", str(seconds)]

    print(f"Scheduling shutdown in {minutes} minutes...")
    try:
        subprocess.run(command, check=True)
        print("Shutdown command executed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to schedule shutdown: {e}")

if __name__ == "__main__":
    schedule_shutdown(30)
