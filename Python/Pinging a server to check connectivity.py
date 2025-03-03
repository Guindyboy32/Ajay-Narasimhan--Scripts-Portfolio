Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import os
... 
... hostname = "google.com"
... response = os.system(f"ping -c 1 {hostname}")
... 
... if response == 0:
...     print(f"{hostname} is up!")
... else:
...     print(f"{hostname} is down!")
... 
