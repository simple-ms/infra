#!/bin/bash
# Logging script for docker-compose
# Captures all container logs and writes them to both console and log file

LOG_FILE="docker-compose-logs.txt"

# Create or clear log file in current directory
> "$LOG_FILE"

echo "Starting docker-compose with logging..."
echo "Logs will be written to: $(pwd)/$LOG_FILE"
echo "Press Ctrl+C to stop"
echo ""

# Run docker-compose and tee output to both console and file
docker-compose up 2>&1 | tee -a "$LOG_FILE"
