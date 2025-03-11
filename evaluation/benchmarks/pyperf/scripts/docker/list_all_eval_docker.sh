#!/bin/bash

NAMESPACE="slimshetty"
REPO="pyperf"
URL="https://hub.docker.com/v2/repositories/${NAMESPACE}/${REPO}/tags?page_size=100"

# Use a temp file to collect all tags
TEMP_FILE=$(mktemp)

# Fetch and store tag names
curl -s "$URL" | jq -r '.results[].name' >> "$TEMP_FILE"

# Check if we need to paginate for more results
NEXT_URL=$(curl -s "$URL" | jq -r '.next')

while [ "$NEXT_URL" != "null" ] && [ -n "$NEXT_URL" ]; do
    curl -s "$NEXT_URL" | jq -r '.results[].name' >> "$TEMP_FILE"
    NEXT_URL=$(curl -s "$NEXT_URL" | jq -r '.next')
done

# Sort and print tags
sort "$TEMP_FILE"

# Count and display total
COUNT=$(wc -l < "$TEMP_FILE")
echo ""
echo "Total tags: $COUNT"

# Clean up
rm "$TEMP_FILE"
