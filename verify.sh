#!/bin/bash

# Simple wrapper script for automated verification
# Usage: ./verify.sh <original_contract> <optimized_contract>

if [ $# -lt 2 ]; then
    echo "Usage: $0 <original_contract> <optimized_contract>"
    echo ""
    echo "Example:"
    echo "  $0 src/Original.sol src/Optimized.sol"
    exit 1
fi

ORIGINAL="$1"
OPTIMIZED="$2"

# Check if files exist
if [ ! -f "$ORIGINAL" ]; then
    echo "Error: Original contract not found: $ORIGINAL"
    exit 1
fi

if [ ! -f "$OPTIMIZED" ]; then
    echo "Error: Optimized contract not found: $OPTIMIZED"
    exit 1
fi

# Run the automated verification
# Add --fast flag for quicker verification: python3 auto_verify.py "$ORIGINAL" "$OPTIMIZED" --fast
python3 auto_verify.py "$ORIGINAL" "$OPTIMIZED"

