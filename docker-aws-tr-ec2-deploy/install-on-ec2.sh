#!/bin/bash

set -ex

# Update the system
sudo yum update -y

# Install and configure Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Git
sudo yum install -y git

# Reboot to ensure all changes take effect
sudo reboot