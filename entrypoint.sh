#!/bin/sh
set -e

# to fix python module issues
export PYTHONPATH=.

# Explicitly set PATH to include user's local bin
export PATH="/home/myuser/.local/bin:$PATH"

# Print current PATH for debugging
echo "Current PATH: $PATH"

# Start Nginx
echo "Starting Nginx..."
nginx

# Start the main application in the background
echo "Starting the main application..."
python3 my_clock.py &

# Keep the container running
wait