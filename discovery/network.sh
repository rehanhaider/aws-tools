#!/bin/bash

# Set AWS profile (if using multiple profiles)
export AWS_PROFILE=upwork_sushil
# List of AWS Regions
REGIONS=(us-east-1 us-east-2 us-west-1 us-west-2)

# Loop through each region and perform the following actions
for REGION in "${REGIONS[@]}"; do
    export AWS_REGION=$REGION
    echo "Processing region: $REGION"

    # Get all VPCs
    echo "Fetching VPCs..."
    aws ec2 describe-vpcs --query 'Vpcs[*].{VpcId:VpcId, CidrBlock:CidrBlock, IsDefault:IsDefault}' --output table

    # Get all subnets
    echo "Fetching subnets..."
    aws ec2 describe-subnets --query 'Subnets[*].{SubnetId:SubnetId, CidrBlock:CidrBlock, VpcId:VpcId}' --output table

    # Check which subnets are public
    echo "Checking which subnets are public..."
    aws ec2 describe-subnets --query 'Subnets[?MapPublicIpOnLaunch==`true`].[SubnetId, CidrBlock, MapPublicIpOnLaunch]' --output table

    # List all Internet Gateways
    echo "Listing all Internet Gateways..."
    aws ec2 describe-internet-gateways --query 'InternetGateways[*].{InternetGatewayId:InternetGatewayId, VpcId:Attachments[0].VpcId}' --output table

    # List all NAT Gateways
    echo "Listing all NAT Gateways..."
    aws ec2 describe-nat-gateways --query 'NatGateways[*].{NatGatewayId:NatGatewayId, VpcId:VpcId, State:State, SubnetId:SubnetId, PublicIp:PublicIp}' --output table

    # List all VPC Endpoints
    echo "Listing all VPC Endpoints..."
    aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[*].{VpcEndpointId:VpcEndpointId, VpcId:VpcId, ServiceName:ServiceName, VpcEndpointType:VpcEndpointType}' --output table

    # List all Load Balancers
    echo "Listing all Load Balancers..."
    aws elbv2 describe-load-balancers --query 'LoadBalancers[*].{LoadBalancerName:LoadBalancerName, DNSName:DNSName, Scheme:Scheme, VpcId:VpcId}' --output table

    # List all VMs along with their public IP addresses and subnet IDs
    echo "Listing all VMs along with their instance ID, Instance name, public IP addresses and subnet IDs..."
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceId:InstanceId, InstanceName:Tags[?Key==`Name`].Value|[0], PublicIp:PublicIpAddress, SubnetId:SubnetId, PrivateIp:PrivateIpAddress}' --output table
done












