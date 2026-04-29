import requests
import logging
from typing import Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def download_file(url: str, local_filename: str, timeout: int = 10) -> Optional[str]:
    """
    Download a file from a URL and save it locally in streaming mode.

    Args:
        url (str): The URL of the file to download.
        local_filename (str): The path where the file will be saved.
        timeout (int): Timeout for the HTTP request in seconds.

    Returns:
        str | None: The path to the downloaded file, or None on failure.
    """
    try:
        with requests.get(url, stream=True, timeout=timeout) as r:
            r.raise_for_status()

            with open(local_filename, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)

        logging.info(f"Downloaded file to: {local_filename}")
        return local_filename

    except requests.exceptions.RequestException as e:
        logging.error(f"Download failed: {e}")
        return None
    except OSError as e:
        logging.error(f"File write failed: {e}")
        return None


if __name__ == "__main__":
    download_file("https://example.com/file.txt", "downloaded_file.txt")
