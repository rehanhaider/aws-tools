#!/bin/bash 

# Stop the instance

# Get the instance ID
INSTANCE_ID=$(aws cloudformation describe-stack-resources --stack-name nucleus-scanner --query "StackResources[?LogicalResourceId=='ScannerInstance'].PhysicalResourceId" --output text)

# Stop the instance
aws ec2 stop-instances --instance-ids "$INSTANCE_ID"

# Wait for the instance to be stopped
aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"

echo "Scanner instance stopped"