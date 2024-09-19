#!/bin/bash

# Clean up script. Before running assure:
# chmod 766 delete-old-tf-workspaces.sh

# Switch to the default workspace first
echo "Switching to default workspace"
terraform workspace select default

# Get all workspaces
workspaces=$(terraform workspace list | sed 's/^[* ] //')

# Loop through each workspace
for workspace in $workspaces; do
    # Skip the 'default' workspace
    if [ "$workspace" != "default" ]; then
        echo "Deleting workspace: $workspace"
        terraform workspace delete -force $workspace
    fi
done

echo "All non-default workspaces have been deleted."