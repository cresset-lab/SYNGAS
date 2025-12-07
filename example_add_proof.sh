#!/bin/bash

# Example: How to Add and Check Proofs for Two Contracts
# This script demonstrates the process step-by-step

set -e

echo "=========================================="
echo "Example: Adding Proof for Two Contracts"
echo "=========================================="
echo ""

# Step 1: Show current contracts
echo "Step 1: Current contracts in src/"
echo "----------------------------------------"
ls -la src/*.sol 2>/dev/null || echo "No contracts found"
echo ""

# Step 2: Build contracts
echo "Step 2: Building contracts..."
echo "----------------------------------------"
forge build
echo "✅ Contracts built successfully"
echo ""

# Step 3: Show test file
echo "Step 3: Test file structure"
echo "----------------------------------------"
echo "Test file: test/GeneralizedEquivalenceTest.t.sol"
echo ""
echo "Key components:"
echo "  - setUp(): Initializes both contracts"
echo "  - assertStateEquivalence(): Checks state matches"
echo "  - check_function_equivalence(): Generic checker"
echo "  - check_equivalence_<function>(): Specific tests"
echo ""

# Step 4: Show how to add a new test
echo "Step 4: How to add a new function test"
echo "----------------------------------------"
cat << 'EOF'
To add a test for a new function, add this to your test file:

function check_equivalence_myNewFunction(uint256 param) public {
    // Add constraints
    vm.assume(param < 100);
    
    // Check equivalence
    check_function_equivalence(
        original.myNewFunction.selector,
        abi.encode(param)
    );
}
EOF
echo ""

# Step 5: Run the proof
echo "Step 5: Running Halmos verification..."
echo "----------------------------------------"
if command -v halmos &> /dev/null; then
    echo "Running: halmos --contract test/GeneralizedEquivalenceTest.t.sol"
    echo ""
    halmos --contract test/GeneralizedEquivalenceTest.t.sol 2>&1 | head -50
else
    echo "⚠️  Halmos not found. Activate virtual environment:"
    echo "   source venv/bin/activate"
    echo ""
    echo "Or install: pip install halmos"
fi
echo ""

# Step 6: Check results
echo "Step 6: Checking results"
echo "----------------------------------------"
if [ -d "proof_results" ]; then
    echo "Results directory: proof_results/"
    ls -lh proof_results/ 2>/dev/null | tail -5
    echo ""
    echo "Latest summary:"
    find proof_results -name "summary_*.txt" -type f -exec ls -t {} \; | head -1 | xargs cat 2>/dev/null || echo "No summary found"
else
    echo "No results directory yet. Run Halmos first."
fi
echo ""

echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Review HOW_TO_ADD_PROOFS.md for detailed guide"
echo "2. Check test/GeneralizedEquivalenceTest.t.sol for examples"
echo "3. Run: ./run_proof_pipeline.sh for automated pipeline"
echo ""

