#!/bin/bash

# Quick verification script - uses fast mode for speed
# Usage: ./QUICK_VERIFY.sh <original_contract> <optimized_contract>

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

# Run with fast mode for quick verification
echo "Running in FAST MODE for quick verification..."
echo "Note: This uses tighter bounds for speed (less coverage)"
echo ""

python3 auto_verify.py "$ORIGINAL" "$OPTIMIZED" --fast

