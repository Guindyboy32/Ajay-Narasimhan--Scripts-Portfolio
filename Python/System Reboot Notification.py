import os
import subprocess
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr
import logging
import platform
import os

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def send_email(subject: str, body: str):
    """
    Send an email notification using SMTP credentials stored in environment variables.
    """

    sender = os.getenv("SMTP_SENDER")
    receiver = os.getenv("SMTP_RECEIVER")
    smtp_server = os.getenv("SMTP_SERVER")
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")

    if not all([sender, receiver, smtp_server, smtp_user, smtp_pass]):
        raise EnvironmentError("Missing SMTP configuration environment variables.")

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = formataddr(("System Automation", sender))
    msg["To"] = receiver

    try:
        with smtplib.SMTP(smtp_server) as server:
            server.login(smtp_user, smtp_pass)
            server.sendmail(sender, receiver, msg.as_string())
        logging.info("Email notification sent.")
    except Exception as e:
        logging.error(f"Failed to send email: {e}")
        raise

def reboot_system():
    """
    Sends a reboot notification email and reboots the system safely.
    Supports Windows and Linux.
    """

    send_email("System Reboot Notification", "The system is about to reboot.")

    try:
        if platform.system() == "Windows":
            logging.info("Rebooting Windows system...")
            subprocess.run(["shutdown", "/r", "/t", "5"], check=True)
        else:
            logging.info("Rebooting Linux system...")
            subprocess.run(["sudo", "reboot"], check=True)

    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to reboot system: {e}")
        raise

if __name__ == "__main__":
    reboot_system()
