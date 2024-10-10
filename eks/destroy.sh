#!/bin/bash

echo "Info: To safely destroy the infrastructure, please run the command: bash destroy.sh --region <region>"
echo "If no region is selected, the script will default to us-west-2."
echo ""
echo "Note: Only the regions us-east-1 and us-west-2 are supported."
echo ""

# Checkpoint file setup
CHECKPOINT_FILE="checkpoint.txt"
VARIABLES_FILE="saved_variables.txt"

# Initialize checkpoint
if [ ! -f "$CHECKPOINT_FILE" ]; then
  echo "START" > "$CHECKPOINT_FILE"
fi

# Load variables if they were saved previously
if [ -f "$VARIABLES_FILE" ]; then
  source "$VARIABLES_FILE"
else
  # Default region
  export DEFAULT_REGION="us-west-2"
  
  # Extract variables and save them to a file
  export REPO_SUFFIX=$(grep "Repo Suffix:" deployment_output.txt | awk '{print $3}')
  export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
  export CLUSTER_NAME=$(grep "EKS Cluster Name:" deployment_output.txt | awk '{print $4}')
  export REPO_NAME=$(grep "ECR Repository Name:" deployment_output.txt | awk '{print $4}')
  export ROLE_NAME=$(grep "EC2 Role Name:" deployment_output.txt | awk '{print $4}')
  export EKS_ROLE_NAME=$(grep "EKS Node Role Name:" deployment_output.txt | awk '{print $5}')
  export BUCKET_NAME=$(grep "S3 Bucket Name:" deployment_output.txt | awk '{print $4}')
  
  # Save the variables to a file for future use
  cat <<EOL > "$VARIABLES_FILE"
export DEFAULT_REGION="$DEFAULT_REGION"
export REPO_SUFFIX="$REPO_SUFFIX"
export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"
export CLUSTER_NAME="$CLUSTER_NAME"
export REPO_NAME="$REPO_NAME"
export ROLE_NAME="$ROLE_NAME"
export EKS_ROLE_NAME="$EKS_ROLE_NAME"
export BUCKET_NAME="$BUCKET_NAME"
EOL
fi

# Check if a region argument is provided, otherwise use the default region
if [ -z "$1" ]; then
  echo "Warning: No region specified. Defaulting to ${DEFAULT_REGION}."
  export REGION=$DEFAULT_REGION
else
  if [[ "$1" == "--region" && -n "$2" ]]; then
    export REGION=$2
  else
    echo "Warning: Unrecognized option or missing region. Please pass the region with --region."
    echo "Usage: $0 --region <region>"
    exit 1
  fi
fi

# Loop through the checkpoints and execute the corresponding actions
while true; do
  CHECKPOINT=$(cat "$CHECKPOINT_FILE")

  case "$CHECKPOINT" in
    "START")
      echo "Deleting all deployments from YAML files..."
      for yaml_file in k8sapp/*.yaml; 
      do
        kubectl delete -f $yaml_file
      done
      echo "CHECKPOINT_1" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_1")
      echo "Deleting EKS cluster with name ${CLUSTER_NAME} in region ${REGION}..."
      eksctl delete cluster --name ${CLUSTER_NAME} --region ${REGION}
      echo "CHECKPOINT_2" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_2")
      # Get the image digest for the latest tag
      export IMAGE_DIGEST=$(aws ecr list-images \
          --repository-name ${REPO_NAME} \
          --filter "tagStatus=TAGGED" \
          --query 'imageIds[?imageTag==`latest`].imageDigest' \
          --output text \
          --region ${REGION})

      # Delete the image using the image digest
      aws ecr batch-delete-image \
          --repository-name ${REPO_NAME} \
          --image-ids imageDigest=${IMAGE_DIGEST} \
          --region ${REGION}

      # Delete the ECR repository
      aws ecr delete-repository \
          --repository-name ${REPO_NAME} \
          --force \
          --region ${REGION}

      echo "CHECKPOINT_3" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_3")
      # Directory containing Terraform configuration
      export TF_DIR="ec2_terraform"

      # Initialize Terraform
      terraform -chdir="$TF_DIR" init

      # Get the instance ARN from Terraform output
      export INSTANCE_ARN=$(jq -r '.instance_arn.value' ec2_output.json)

      if [ -z "$INSTANCE_ARN" ]; then
        echo "Error: No instance ARN found in Terraform output. Please ensure the correct region is specified."
        exit 1
      fi

      # Extract the region from the instance ARN
      ARN_REGION=$(echo "$INSTANCE_ARN" | cut -d':' -f4)

      if [ "$ARN_REGION" != "$REGION" ]; then
        echo "Error: Instance region $ARN_REGION does not match specified region $REGION."
        exit 1
      fi

      # Verify instance existence in the specified region
      export INSTANCE_ID=$(jq -r '.instance_arn.value | split(":") | .[-1] | split("/") | .[-1]' ec2_output.json) 
      INSTANCE_EXISTS=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" --query "Reservations[*].Instances[*].InstanceId" --output text)

      if [ "$INSTANCE_EXISTS" != "$INSTANCE_ID" ]; then
        echo "Error: Instance $INSTANCE_ID does not exist in region $REGION."
        exit 1
      fi

      # Destroy Terraform-managed infrastructure
      terraform -chdir="$TF_DIR" destroy -var="region=$REGION" -auto-approve

      sed -i 's|image: .*|image: IMAGE_PLACEHOLDER|' k8sapp/deployment.yaml
      sed -i 's|image: .*\.amazonaws\.com/.*|image: IMAGE_PLACEHOLDER|' k8sapp/cron_job.yaml

      echo "CHECKPOINT_4" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_4")
      # Delete IAM role and policy for ec2 instance
      # Remove the role from the instance profile
      aws iam remove-role-from-instance-profile --instance-profile-name peachycloudsecurity-ip --role-name peachycloudsecurity-redteam-${REPO_SUFFIX}
      # Delete the instance profile
      aws iam delete-instance-profile --instance-profile-name peachycloudsecurity-ip
      # Delete the inline policy from the IAM role
      aws iam delete-role-policy --role-name peachycloudsecurity-redteam-${REPO_SUFFIX} --policy-name peachycloudsecurity-policy
      # Delete the IAM role
      aws iam delete-role --role-name peachycloudsecurity-redteam-${REPO_SUFFIX}

      echo "CHECKPOINT_5" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_5")
      # Delete IAM role and policy for eks node instance
      echo "Removing IAM role & policies for eks role name: ${EKS_ROLE_NAME}..."

      aws iam detach-role-policy --role-name ${EKS_ROLE_NAME} --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/peachycloudsecurity-listSpecificS3Buckets
      aws iam remove-role-from-instance-profile --instance-profile-name ${EKS_ROLE_NAME}-profile --role-name ${EKS_ROLE_NAME}
      aws iam delete-instance-profile --instance-profile-name ${EKS_ROLE_NAME}-profile
      aws iam list-attached-role-policies --role-name ${EKS_ROLE_NAME} --query 'AttachedPolicies[].PolicyArn' --output text | xargs -n1 aws iam detach-role-policy --role-name ${EKS_ROLE_NAME} --policy-arn

      aws iam delete-role --role-name ${EKS_ROLE_NAME}

      aws iam list-policy-versions --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/peachycloudsecurity-listSpecificS3Buckets" --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text | xargs -I {} aws iam delete-policy-version --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/peachycloudsecurity-listSpecificS3Buckets" --version-id {} && aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/peachycloudsecurity-listSpecificS3Buckets"

      echo "CHECKPOINT_6" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_6")
      # Verify if destruction was successful
      if [ $? -eq 0 ]; then
        # Delete additional files and directories
        echo "Deleting additional files and directories..."
        rm -rf ec2_terraform/.terraform \
               ec2_terraform/terraform.tfstate \
               ec2_terraform/terraform.tfstate.backup \
               ec2_terraform/.terraform.lock.hcl \
               deployment_output.txt \
               ec2_output.json \
               ec2_terraform/trust-policy.json \
               ec2_terraform/ec2_policy.json \
               trust-policy.json \
               repo_name.txt \
               repo_url.txt \
               eks-cluster-config.yaml \
               flag.txt \
               peachycloudsecurity-eks-policy.json \
               peachycloudsecurity-ekstrust-policy.json
        echo "Cleanup completed."
      else
        echo "Error: Failed to destroy infrastructure."
        exit 1
      fi

      echo "CHECKPOINT_7" > "$CHECKPOINT_FILE"
      ;;

    "CHECKPOINT_7")
      echo "Deleting the S3 Bucket..."
      # Delete the flag.txt file from the S3 bucket
      aws s3 rm s3://${BUCKET_NAME}/flag.txt

      # Delete the S3 bucket
      aws s3 rb s3://${BUCKET_NAME} --force

      echo "All deployments deleted successfully."

      # Final cleanup of checkpoint file
      rm "$CHECKPOINT_FILE"
      rm "$VARIABLES_FILE"

      # Exit the loop and script
      break
      ;;
  esac
done
