import boto3
from datetime import datetime, timezone
import os
def lambda_handler(event, contect):
    bucket_name = os.environ['BUCKET_NAME']
    aws_client = boto3.client("s3")
    current_time = datetime.now(timezone.utc)
    bucket_objects = aws_client.list_objects_v2(Bucket=bucket_name)
    if 'Contents' in bucket_objects:
        for obj in bucket_objects['Contents']:
            modified_date = obj['LastModified']
            date_diff = (current_time - modified_date).days
            if date_diff > 7:
                print(f"older file going to delete {obj['Key']} - age - {date_diff}")
                aws_client.delete_object(Bucket=bucket_name, Key=obj['Key'])
                out = {"status": "CleanupCompleted"}
            else:
                out = {"status": "CleanupNA"}

    else:
        print("No object in bucket")
        out = {"status": "NoObjects"}
    return out
