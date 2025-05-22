import boto3
from botocore.exceptions import ClientError
from concurrent.futures import ThreadPoolExecutor
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_ec2_resources(region):
    """List EC2 instances and related resources in a region."""
    try:
        ec2 = boto3.client('ec2', region_name=region)
        resources = {
            'instances': ec2.describe_instances()['Reservations'],
            'volumes': ec2.describe_volumes()['Volumes'],
            'snapshots': ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']
        }
        return resources
    except ClientError as e:
        logger.error(f"Error getting EC2 resources in {region}: {e}")
        return {}

def get_rds_resources(region):
    """List RDS instances and related resources."""
    try:
        rds = boto3.client('rds', region_name=region)
        return {
            'instances': rds.describe_db_instances()['DBInstances'],
            'snapshots': rds.describe_db_snapshots()['DBSnapshots']
        }
    except ClientError as e:
        logger.error(f"Error getting RDS resources in {region}: {e}")
        return {}

def get_s3_resources():
    """List S3 buckets and their sizes."""
    try:
        s3 = boto3.client('s3')
        return {
            'buckets': s3.list_buckets()['Buckets']
        }
    except ClientError as e:
        logger.error(f"Error getting S3 resources: {e}")
        return {}

def list_aws_resources():
    """
    List all AWS resources that incur costs across regions.
    Returns a dictionary of resources grouped by service and region.
    """
    ec2 = boto3.client('ec2')
    regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]
    
    all_resources = {
        'EC2': {},
        'RDS': {},
        'S3': get_s3_resources()  # S3 is global
    }
    
    # Use ThreadPoolExecutor to parallel process regions
    with ThreadPoolExecutor(max_workers=10) as executor:
        # EC2 resources
        ec2_futures = {executor.submit(get_ec2_resources, region): region 
                      for region in regions}
        for future in ec2_futures:
            region = ec2_futures[future]
            all_resources['EC2'][region] = future.result()
            
        # RDS resources
        rds_futures = {executor.submit(get_rds_resources, region): region 
                      for region in regions}
        for future in rds_futures:
            region = rds_futures[future]
            all_resources['RDS'][region] = future.result()
    
    return all_resources

def filter_costly_resources(resources):
    """
    Filter and organize resources based on cost implications.
    
    Args:
        resources (dict): Dictionary of AWS resources by service and region
    
    Returns:
        dict: Filtered resources that typically incur costs
    """
    costly_resources = {
        'EC2': {
            'running_instances': [],
            'unused_volumes': [],
            'old_snapshots': []
        },
        'RDS': {
            'running_instances': [],
            'old_snapshots': []
        },
        'S3': {
            'large_buckets': []
        }
    }
    
    # Process EC2 resources
    for region, ec2_resources in resources['EC2'].items():
        for reservation in ec2_resources.get('instances', []):
            for instance in reservation['Instances']:
                if instance['State']['Name'] == 'running':
                    costly_resources['EC2']['running_instances'].append({
                        'region': region,
                        'id': instance['InstanceId'],
                        'type': instance['InstanceType']
                    })
    
    return costly_resources

def main():
    logger.info("Starting AWS resource discovery...")
    resources = list_aws_resources()
    costly_resources = filter_costly_resources(resources)
    
    # Print findings in a structured format
    for service, resource_types in costly_resources.items():
        print(f"\n=== {service} Resources ===")
        for resource_type, items in resource_types.items():
            print(f"\n{resource_type.replace('_', ' ').title()}:")
            for item in items:
                print(f"  - {item}")

if __name__ == "__main__":
    main()