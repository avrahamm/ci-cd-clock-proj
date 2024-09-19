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
