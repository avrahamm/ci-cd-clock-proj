#!/bin/bash
set -e

# to fix python module issues
export PYTHONPATH=.

# Explicitly set PATH to include user's local bin
export PATH="/home/myuser/.local/bin:$PATH"

# Print current PATH for debugging
echo "Current PATH: $PATH"

# Run the Pytest tests
echo "Running Pytest tests..."
/home/myuser/.local/bin/pytest tests/test_my_clock.py

# Start Nginx
echo "Starting Nginx..."
nginx

# Start the main application in the background
echo "Starting the main application..."
python3 my_clock.py &

# Run the E2E tests
echo "Running E2E tests..."
python3 tests/test_my_clock_e2e.py

# Wait E2E tests to complete
sleep 30

# Stop the application and Nginx
echo "Stopping the application and Nginx..."
kill %1
sudo nginx -s stop