import schedule
import time
import logging
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def job():
    """
    The scheduled task to run.
    """
    logging.info("Scheduled task executed.")

def run_scheduler(schedule_time: str = "10:00"):
    """
    Run the scheduler loop and handle errors gracefully.

    Args:
        schedule_time (str): Time of day to run the job (HH:MM format).
    """
    schedule.every().day.at(schedule_time).do(job)
    logging.info(f"Scheduler started. Task scheduled for {schedule_time} daily.")

    try:
        while True:
            schedule.run_pending()
            time.sleep(1)
    except KeyboardInterrupt:
        logging.info("Scheduler stopped by user.")
    except Exception as e:
        logging.error(f"Scheduler encountered an error: {e}")

if __name__ == "__main__":
    run_scheduler("10:00")
