#!/bin/bash

INSTANCE_ID=$1
REGION=$2

# Function to check EC2 instance status
check_instance_status() {
  while true; do
    STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --region $REGION --query 'InstanceStatuses[*].InstanceStatus.Status' --output text)
    if [[ "$STATUS" == "ok" ]]; then
      echo "EC2 instance is running."
      break
    else
      echo "Waiting for EC2 instance to be running..."
      sleep 10
    fi
  done
}


# Check instance status
check_instance_status


