#!/bin/bash
set -e

# Check if namespace is provided via argument $3, otherwise default to 'slimshetty'
NAMESPACE=${1:-slimshetty}

echo "Using namespace: $NAMESPACE"

IMAGE_FILE="$(dirname "$0")/all-pyperf-instance-images.txt"
PATTERN="pyperf.eval"

echo "Pulling docker images"
echo "Pattern: $PATTERN"
echo "Image file: $IMAGE_FILE"

# Read each line from the file, filter by pattern, and pull the docker image
grep "$PATTERN" "$IMAGE_FILE" | while IFS= read -r image; do
    echo "Pulling $NAMESPACE/$image into $image"
    docker pull $NAMESPACE/$image
done
