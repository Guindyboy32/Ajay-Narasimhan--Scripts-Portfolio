Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import subprocess
... 
... # List of software to install
... software_list = [
...     'software1',
...     'software2',
...     'software3'
... ]
... 
... def install_software(software):
...     try:
...         subprocess.check_call(['pip', 'install', software])
...         print(f"{software} installed successfully.")
...     except subprocess.CalledProcessError:
...         print(f"Failed to install {software}.")
... 
... for software in software_list:
...     install_software(software)
... 
... 
... 
... 
