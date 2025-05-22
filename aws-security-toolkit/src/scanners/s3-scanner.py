import boto3
from botocore.exceptions import ClientError

def list_buckets():
    """List all S3 buckets in the account."""
    s3 = boto3.client('s3')
    try:
        response = s3.list_buckets()
        return [bucket['Name'] for bucket in response['Buckets']]
    except ClientError as e:
        print(f"Error listing buckets: {e}")
        return []

def evaluate_bucket_configuration(bucket_name):
    """Evaluate the configuration of a specific S3 bucket."""
    s3 = boto3.client('s3')
    try:
        # Example checks for bucket configuration
        bucket_policy = s3.get_bucket_policy(Bucket=bucket_name)
        # Add more checks as needed
        return {
            'BucketName': bucket_name,
            'Policy': bucket_policy['Policy']
        }
    except ClientError as e:
        print(f"Error evaluating bucket configuration for {bucket_name}: {e}")
        return None

def scan_s3_buckets():
    """Scan all S3 buckets for misconfigurations."""
    buckets = list_buckets()
    results = []
    for bucket in buckets:
        config = evaluate_bucket_configuration(bucket)
        if config:
            results.append(config)
    return results

if __name__ == "__main__":
    misconfigured_buckets = scan_s3_buckets()
    print("Misconfigured S3 Buckets:", misconfigured_buckets)