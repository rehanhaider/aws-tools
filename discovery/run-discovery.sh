#!/bin/bash

# Set AWS profile (if using multiple profiles)
export AWS_PROFILE=upwork_sushil

echo "Discovering AWS resources..."

# Get all tagged resources
echo "Fetching resources from Resource Groups Tagging API..."
aws resourcegroupstaggingapi get-resources --output table

# List S3 Buckets
echo "Fetching S3 buckets..."
aws s3 ls --output table

# List EC2 Instances
echo "Fetching EC2 instances..."
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output table

# List Lambda Functions
echo "Fetching Lambda functions..."
aws lambda list-functions --query 'Functions[*].FunctionName' --output table

# List RDS Instances
echo "Fetching RDS instances..."
aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output table

# List DynamoDB Tables
echo "Fetching DynamoDB tables..."
aws dynamodb list-tables --output table

# List VPCs
echo "Fetching VPCs..."
aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output table

# List Load Balancers
echo "Fetching Load Balancers..."
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerName' --output table

# List CloudFormation Stacks
echo "Fetching CloudFormation stacks..."
aws cloudformation list-stacks \
    --stack-status-filter CREATE_IN_PROGRESS CREATE_COMPLETE UPDATE_COMPLETE \
    --query 'StackSummaries[*].StackName' --output table


echo "AWS resource discovery completed. Check the output files."
