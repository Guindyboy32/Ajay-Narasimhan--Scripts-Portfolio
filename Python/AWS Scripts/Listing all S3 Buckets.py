Python 3.13.1 (tags/v3.13.1:0671451, Dec  3 2024, 19:06:28) [MSC v.1942 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> import boto3
... 
... def list_s3_buckets():
...     s3 = boto3.client('s3')
...     response = s3.list_buckets()
...     
...     print("Your S3 buckets:")
...     for bucket in response['Buckets']:
...         print(f"- {bucket['Name']}")
... 
... list_s3_buckets()
