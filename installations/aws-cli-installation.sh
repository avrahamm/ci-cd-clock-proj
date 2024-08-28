#!/bin/bash
set -e

# Update package list
apt-get update

# Install unzip
apt-get install -y unzip

# Download the AWS CLI archive
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the archive
unzip awscliv2.zip

# Install AWS CLI
./aws/install

# Verify installation
aws --version

# Clean up
rm -rf aws awscliv2.zip

echo "AWS CLI has been successfully installed."