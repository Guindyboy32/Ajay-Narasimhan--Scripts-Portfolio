Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import os
... 
... def schedule_shutdown(minutes):
...     os.system(f"sudo shutdown -h +{minutes}")
...     print(f"System will shut down in {minutes} minutes.")
... 
... if __name__ == "__main__":
...     schedule_shutdown(30)  # Shutdown in 30 minutes
... 
... 
... 
... 
... 
... 
