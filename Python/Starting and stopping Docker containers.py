Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import docker
... 
... client = docker.from_env()
... 
... def start_container(container_name):
...     try:
...         container = client.containers.get(container_name)
...         container.start()
...         print(f"Container {container_name} started successfully.")
...     except docker.errors.NotFound:
...         print(f"Container {container_name} not found.")
...     except Exception as e:
...         print(f"Error starting container: {e}")
... 
... def stop_container(container_name):
...     try:
...         container = client.containers.get(container_name)
...         container.stop()
...         print(f"Container {container_name} stopped successfully.")
...     except docker.errors.NotFound:
...         print(f"Container {container_name} not found.")
...     except Exception as e:
...         print(f"Error stopping container: {e}")
... 
... start_container('my_container')
... stop_container('my_container')
... 
... 
