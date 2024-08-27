#!/bin/bash

# terraform-installation.sh
# Need to run this script on jenkins server
# to run terraform commands from Jenkinsfile.

# Exit immediately if a command exits with a non-zero status
set -e

# Update package list
apt-get update

# Install required packages
apt-get install -y wget unzip jq

# Fetch the latest Terraform version
TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)

echo "Latest Terraform version is ${TERRAFORM_VERSION}"

# Download Terraform
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Unzip Terraform
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Move Terraform to a directory in the PATH
mv terraform /usr/local/bin/

# Verify installation
terraform --version

# Clean up
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

echo "Terraform ${TERRAFORM_VERSION} has been successfully installed."