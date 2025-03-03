Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import platform
... import psutil
... 
... def get_system_info():
...     system_info = {
...         'System': platform.system(),
...         'Node Name': platform.node(),
...         'Release': platform.release(),
...         'Version': platform.version(),
...         'Machine': platform.machine(),
...         'Processor': platform.processor(),
...         'CPU Cores': psutil.cpu_count(logical=False),
...         'Logical CPUs': psutil.cpu_count(logical=True),
...         'Memory': psutil.virtual_memory().total // (1024 ** 3),
...         'Disk Space': psutil.disk_usage('/').total // (1024 ** 3)
...     }
...     
...     for key, value in system_info.items():
...         print(f"{key}: {value}")
... 
... get_system_info()
... 
... 
... 
... 
