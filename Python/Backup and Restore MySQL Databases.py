Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import subprocess
... 
... def backup_database(db_name, user, password, backup_file):
...     try:
...         command = f"mysqldump -u {user} -p{password} {db_name} > {backup_file}"
...         subprocess.run(command, shell=True, check=True)
...         print("Database backup completed successfully.")
...     except subprocess.CalledProcessError as e:
...         print(f"Error backing up database: {e}")
... 
... def restore_database(db_name, user, password, backup_file):
...     try:
...         command = f"mysql -u {user} -p{password} {db_name} < {backup_file}"
...         subprocess.run(command, shell=True, check=True)
...         print("Database restored successfully.")
...     except subprocess.CalledProcessError as e:
...         print(f"Error restoring database: {e}")
... 
... backup_database('my_database', 'root', 'password', 'backup.sql')
... # To restore: restore_database('my_database', 'root', 'password', 'backup.sql')
... 
... 
