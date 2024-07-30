#!/bin/bash
set -e

# to fix python module issues
export PYTHONPATH=.

# Run the Pytest tests
echo "Running Pytest tests..."
pytest tests/test_my_clock.py

# Start Nginx
echo "Starting Nginx..."
nginx

# Start the main application in the background
echo "Starting the main application..."
python3 my_clock.py &

# Run the E2E tests
echo "Running E2E tests..."
python3 tests/test_my_clock_e2e.py
