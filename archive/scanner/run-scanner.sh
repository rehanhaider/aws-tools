#!/bin/bash

USER_DATA=$(base64 -w 0 scanner/setup-scanner.sh)

# Create the stack
aws cloudformation create-stack \
--stack-name entropic-scanner \
--template-body file://scanner/instance.yaml \
--parameters ParameterKey=AMI,ParameterValue="ami-04b4f1a9cf54c11d0" \
    ParameterKey=KeyName,ParameterValue="MyKP" \
    ParameterKey=UserData,ParameterValue="$USER_DATA"

# Wait for the stack to be created
echo "Waiting for the stack to be created"
aws cloudformation wait stack-create-complete --stack-name nucleus-scanner

echo "Stack created"

# Get the instance ID
INSTANCE_ID=$(aws cloudformation describe-stack-resources --stack-name nucleus-scanner --query "StackResources[?LogicalResourceId=='ScannerInstance'].PhysicalResourceId" --output text)

# Get the public IP address

# Wait for the instance to be running
echo "Waiting for the instance to be running"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

echo "Scanner instance is running"

# Wait for the instance to be in a running state
echo "Waiting for the status check to be ok"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

echo "Scanner instance is in a running state"

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo -e "Scanner instance created with public IP address: \n$PUBLIC_IP"
