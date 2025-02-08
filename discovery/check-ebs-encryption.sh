#!/bin/bash

# Set AWS profile (if using multiple profiles)
export AWS_PROFILE=upwork_sushil

echo "Checking EBS encryption..."

# Get all EBS volumes and store them in a JSON file
echo "Fetching all EBS volumes..."
aws ec2 describe-volumes --query 'Volumes[*].VolumeId' --output json > ebs_volumes.json

# Check if the JSON file is empty
if [ ! -s ebs_volumes.json ]; then
    echo "No EBS volumes found."
    exit 1
fi

# Check encryption settings for each volume
echo "Checking encryption settings for each volume..."
for volume in $(jq -r '.[]' ebs_volumes.json); do
    echo "Volume: $volume"
    aws ec2 describe-volumes --volume-ids "$volume" --query 'Volumes[*].Encrypted' --output text
done
