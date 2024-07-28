#!/bin/bash
set -e

# to fix python module issues
export PYTHONPATH=.

# Run the tests
echo "Running tests..."
pytest

# If tests pass, start Nginx
echo "Starting Nginx..."
nginx

# Run the main application
echo "Starting the main application..."
python3 my_clock.py