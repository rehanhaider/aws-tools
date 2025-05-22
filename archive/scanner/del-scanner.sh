#!/bin/bash 

# Delete the stack
aws cloudformation delete-stack --stack-name entropic-scanner

# Wait for the stack to be deleted
aws cloudformation wait stack-delete-complete --stack-name entropic-scanner

echo "Scanner stack deleted"