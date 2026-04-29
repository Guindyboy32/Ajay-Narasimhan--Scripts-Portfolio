import docker
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

class DockerManager:
    """
    A simple wrapper around the Docker SDK to manage containers.
    """

    def __init__(self):
        try:
            self.client = docker.from_env()
        except Exception as e:
            logging.error(f"Failed to initialize Docker client: {e}")
            raise

    def start_container(self, container_name: str) -> bool:
        """
        Start a Docker container by name.
        """
        try:
            container = self.client.containers.get(container_name)
            container.start()
            logging.info(f"Container '{container_name}' started successfully.")
            return True
        except docker.errors.NotFound:
            logging.error(f"Container '{container_name}' not found.")
        except Exception as e:
            logging.error(f"Error starting container '{container_name}': {e}")
        return False

    def stop_container(self, container_name: str) -> bool:
        """
        Stop a Docker container by name.
        """
        try:
            container = self.client.containers.get(container_name)
            container.stop()
            logging.info(f"Container '{container_name}' stopped successfully.")
            return True
        except docker.errors.NotFound:
            logging.error(f"Container '{container_name}' not found.")
        except Exception as e:
            logging.error(f"Error stopping container '{container_name}': {e}")
        return False


if __name__ == "__main__":
    manager = DockerManager()
    manager.start_container("my_container")
    manager.stop_container("my_container")
... 
