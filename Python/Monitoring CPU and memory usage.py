Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import psutil
... 
... cpu_usage = psutil.cpu_percent(interval=1)
... memory_info = psutil.virtual_memory()
... 
... print(f"CPU Usage: {cpu_usage}%")
... print(f"Memory Usage: {memory_info.percent}%")
... 
