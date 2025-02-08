#!/bin/bash 

# Delete the stack
aws cloudformation delete-stack --stack-name nucleus-scanner

# Wait for the stack to be deleted
aws cloudformation wait stack-delete-complete --stack-name nucleus-scanner

echo "Scanner stack deleted"