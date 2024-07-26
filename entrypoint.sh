#!/bin/bash
set -e

# Run the tests
echo "Running tests..."
python3 -m unittest discover tests

# If tests pass, start Nginx
echo "Starting Nginx..."
nginx

# Run the main application
echo "Starting the main application..."
python3 my_clock.py