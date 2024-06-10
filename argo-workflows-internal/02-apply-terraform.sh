#!/bin/sh

# Arguments
APPLICATION_NAME=$1
ROLE_NAME=$2
BUCKET_NAME=$3
ARTIFACT_BUCKET=$4

# Directory where Terraform configuration is located
TF_DIR="/mnt/vol/terraform-examples/environments/dev/app-infra/python-basic-app/"
# TF_DIR="/tmp/terraform-examples/environments/dev/app-infra/python-basic-app/"

# Ensure target directory exists
if [ ! -d "${TF_DIR}" ]; then
  echo "Terraform configuration directory does not exist: ${TF_DIR}"
  exit 1
fi

# Navigate to the Terraform configuration directory
cd ${TF_DIR} || exit

# Create terraform.tfvars file with the provided values
cat <<EOF > terraform.tfvars
application_name = "${APPLICATION_NAME}"
role_name = "${ROLE_NAME}"
bucket_name = "${BUCKET_NAME}"
artifact_bucket = "${ARTIFACT_BUCKET}"
EOF

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -var-file=terraform.tfvars -auto-approve

# Check if Terraform apply was successful
if [ $? -ne 0 ]; then
  echo "Terraform apply failed."
  exit 1
fi

echo "Terraform apply completed successfully."

# Upload the state file to the S3 bucket
STATE_FILE="terraform.tfstate"
if [ -f "${STATE_FILE}" ]; then
  aws s3 cp ${STATE_FILE} s3://${ARTIFACT_BUCKET}/${APPLICATION_NAME}/terraform.tfstate
  if [ $? -ne 0 ]; then
    echo "Failed to upload the state file to S3."
    exit 1
  fi
  echo "State file uploaded to S3 successfully."
else
  echo "State file does not exist."
  exit 1
fi
