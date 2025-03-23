#!/bin/bash
# Script to automatically fix common Credo issues

# Format code with mix format
echo "Formatting code..."
docker-compose run --rm dev mix format

# Run Credo and save issues to a file
echo "Running Credo and saving issues..."
docker-compose run --rm dev mix credo --format json > credo_issues.json

# Process the issues (for now, just show them)
echo "Issues found:"
cat credo_issues.json | grep -i "message"

# Cleanup
rm credo_issues.json

echo "Done! Please review and fix remaining issues manually."