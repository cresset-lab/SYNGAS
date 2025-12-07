#!/bin/bash

# Script to extract and display counterexamples from Halmos logs

if [ $# -eq 0 ]; then
    # Find the most recent log file
    LOG_FILE=$(ls -t proof_results/halmos_*.log 2>/dev/null | head -1)
else
    LOG_FILE="$1"
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: No Halmos log file found"
    echo "Usage: $0 [log_file]"
    exit 1
fi

echo "Extracting counterexample from: $LOG_FILE"
echo ""

# Extract counterexample information
python3 << EOF
import re
import sys

with open("$LOG_FILE", 'r') as f:
    content = f.read()

# Find FAIL lines
fail_pattern = r'\[FAIL\]\s+(\w+)\([^)]*\)'
fails = re.findall(fail_pattern, content)

# Find counterexamples
counterexample_pattern = r'Counterexample:\s*\n\s*(.*?)(?=\[|$)'
counterexamples = re.findall(counterexample_pattern, content, re.MULTILINE | re.DOTALL)

print("=" * 70)
print("COUNTEREXAMPLE ANALYSIS")
print("=" * 70)
print()

if fails:
    print("Failed Tests:")
    for fail in fails:
        print(f"  ❌ {fail}()")
    print()

if counterexamples:
    print("Counterexample Values:")
    for i, ce in enumerate(counterexamples, 1):
        lines = ce.strip().split('\n')
        for line in lines:
            line = line.strip()
            if line and '=' in line:
                # Parse variable = value
                parts = line.split('=')
                if len(parts) == 2:
                    var = parts[0].strip()
                    val = parts[1].strip()
                    
                    # Try to convert hex to decimal
                    if val.startswith('0x'):
                        try:
                            dec_val = int(val, 16)
                            print(f"  {var} = {val} (hex) = {dec_val} (decimal)")
                        except:
                            print(f"  {var} = {val}")
                    else:
                        print(f"  {var} = {val}")
    print()

# Try to extract function name and parameters
if fails and counterexamples:
    print("=" * 70)
    print("INTERPRETATION")
    print("=" * 70)
    print()
    print("The counterexample shows input values that cause the contracts")
    print("to behave differently (one succeeds, one fails).")
    print()
    print("This indicates the contracts are NOT equivalent.")
    print("=" * 70)
EOF

