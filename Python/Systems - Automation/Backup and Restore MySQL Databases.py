import subprocess
import logging
from typing import Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def backup_database(db_name: str, user: str, password: str, backup_file: str) -> bool:
    """
    Safely back up a MySQL database using mysqldump.

    Args:
        db_name (str): Name of the database.
        user (str): MySQL username.
        password (str): MySQL password.
        backup_file (str): Output .sql file path.

    Returns:
        bool: True if successful, False otherwise.
    """
    try:
        cmd = ["mysqldump", "-u", user, f"-p{password}", db_name]

        with open(backup_file, "wb") as f:
            process = subprocess.Popen(cmd, stdout=f, stderr=subprocess.PIPE)
            _, err = process.communicate()

        if process.returncode == 0:
            logging.info(f"Backup completed: {backup_file}")
            return True
        else:
            logging.error(f"Backup failed: {err.decode().strip()}")
            return False

    except FileNotFoundError:
        logging.error("mysqldump not found. Ensure MySQL tools are installed.")
        return False
    except Exception as e:
        logging.error(f"Unexpected error during backup: {e}")
        return False


def restore_database(db_name: str, user: str, password: str, backup_file: str) -> bool:
    """
    Safely restore a MySQL database from a .sql file.

    Args:
        db_name (str): Name of the database.
        user (str): MySQL username.
        password (str): MySQL password.
        backup_file (str): Path to the .sql backup file.

    Returns:
        bool: True if successful, False otherwise.
    """
    try:
        cmd = ["mysql", "-u", user, f"-p{password}", db_name]

        with open(backup_file, "rb") as f:
            process = subprocess.Popen(cmd, stdin=f, stderr=subprocess.PIPE)
            _, err = process.communicate()

        if process.returncode == 0:
            logging.info("Database restored successfully.")
            return True
        else:
            logging.error(f"Restore failed: {err.decode().strip()}")
            return False

    except FileNotFoundError:
        logging.error("mysql client not found. Ensure MySQL tools are installed.")
        return False
    except Exception as e:
        logging.error(f"Unexpected error during restore: {e}")
        return False


if __name__ == "__main__":
    backup_database("my_database", "root", "password", "backup.sql")
    # restore_database("my_database", "root", "password", "backup.sql")
