#!/bin/bash
set -e

# to fix python module issues
export PYTHONPATH=.

# Run the tests
echo "Running pytest tests..."
pytest tests/test_my_clock.py

# If tests pass, start Nginx
echo "Starting Nginx..."
nginx

# Run the main application
echo "Starting the main application and e2e tests..."
python3 my_clock.py && python3 tests/test_my_clock_e2e.py

# Run e2e tests
#echo "Running e2e tests..."
#python3 tests/test_my_clock_e2e.py