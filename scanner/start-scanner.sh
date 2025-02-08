#!/bin/bash 

# Get the instance ID
INSTANCE_ID=$(aws cloudformation describe-stack-resources --stack-name nucleus-scanner --query "StackResources[?LogicalResourceId=='ScannerInstance'].PhysicalResourceId" --output text)

# Start the instance
aws ec2 start-instances --instance-ids "$INSTANCE_ID"

# Wait for the instance to be started
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get the public IP 
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Scanner instance started at $PUBLIC_IP"