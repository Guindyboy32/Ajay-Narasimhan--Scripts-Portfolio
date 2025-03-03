Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import os
... import shutil
... 
... def clean_temp_files(temp_dir):
...     for root, dirs, files in os.walk(temp_dir):
...         for file in files:
...             file_path = os.path.join(root, file)
...             try:
...                 os.remove(file_path)
...                 print(f"Deleted file: {file_path}")
...             except Exception as e:
...                 print(f"Error deleting file {file_path}: {e}")
... 
... def clean_temp_directories(temp_dir):
...     for root, dirs, files in os.walk(temp_dir):
...         for dir in dirs:
...             dir_path = os.path.join(root, dir)
...             try:
...                 shutil.rmtree(dir_path)
...                 print(f"Deleted directory: {dir_path}")
...             except Exception as e:
...                 print(f"Error deleting directory {dir_path}: {e}")
... 
... temp_dir = '/path/to/temp_directory'
... clean_temp_files(temp_dir)
... clean_temp_directories(temp_dir)
... 
... 
... 
... 
