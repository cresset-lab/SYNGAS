#!/bin/bash

# ============================================================================
# Halmos Equivalence Proof Pipeline
# ============================================================================
# This script automates the process of:
# 1. Building Solidity contracts
# 2. Generating test harnesses (optional)
# 3. Running Halmos symbolic verification
# 4. Reporting results
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILE="${1:-test/GeneralizedEquivalenceTest.t.sol}"
GENERATE_TESTS="${GENERATE_TESTS:-false}"
HALMOS_ARGS="${HALMOS_ARGS:---solver-timeout-assertion 0 --solver-timeout-unknown 0}"
OUTPUT_DIR="${OUTPUT_DIR:-proof_results}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Build contracts
build_contracts() {
    log_info "Building Solidity contracts..."
    cd "$PROJECT_ROOT"
    
    if forge build --force 2>&1 | tee /tmp/forge_build.log; then
        log_success "Contracts built successfully"
        return 0
    else
        log_error "Contract build failed"
        return 1
    fi
}

# Step 2: Generate test harness (optional)
generate_test_harness() {
    if [ "$GENERATE_TESTS" = "true" ]; then
        log_info "Generating test harness..."
        cd "$PROJECT_ROOT"
        
        if [ -f "generate_proof.py" ]; then
            if python3 generate_proof.py 2>&1 | tee /tmp/test_generation.log; then
                log_success "Test harness generated"
                return 0
            else
                log_warning "Test harness generation failed, continuing with existing tests"
                return 1
            fi
        else
            log_warning "generate_proof.py not found, skipping test generation"
            return 1
        fi
    else
        log_info "Skipping test generation (set GENERATE_TESTS=true to enable)"
        return 0
    fi
}

# Step 3: Run Halmos
run_halmos() {
    log_info "Running Halmos symbolic verification on $TEST_FILE..."
    cd "$PROJECT_ROOT"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Get timestamp for unique output file
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT_FILE="$OUTPUT_DIR/halmos_${TIMESTAMP}.log"
    
    # Check if halmos is available
    if ! command -v halmos &> /dev/null; then
        log_error "Halmos not found. Please install it or activate your virtual environment."
        log_info "Try: source venv/bin/activate"
        return 1
    fi
    
    # Run Halmos
    log_info "Command: halmos $HALMOS_ARGS --contract $TEST_FILE"
    
    if halmos $HALMOS_ARGS --contract "$TEST_FILE" 2>&1 | tee "$OUTPUT_FILE"; then
        log_success "Halmos verification completed"
        log_info "Results saved to: $OUTPUT_FILE"
        
        # Parse results
        parse_results "$OUTPUT_FILE"
        return 0
    else
        EXIT_CODE=$?
        log_error "Halmos verification failed with exit code $EXIT_CODE"
        log_info "Check the output file: $OUTPUT_FILE"
        return $EXIT_CODE
    fi
}

# Step 4: Parse and report results
parse_results() {
    local output_file="$1"
    
    log_info "Parsing results from $output_file..."
    
    # Extract key metrics
    local total_tests=$(grep -c "check_equivalence_" "$output_file" || echo "0")
    local passed=$(grep -c "PASS" "$output_file" || echo "0")
    local failed=$(grep -c "FAIL" "$output_file" || echo "0")
    local counterexamples=$(grep -c "Counterexample" "$output_file" || echo "0")
    
    # Create summary
    SUMMARY_FILE="$OUTPUT_DIR/summary_${TIMESTAMP}.txt"
    {
        echo "=========================================="
        echo "Halmos Equivalence Proof Summary"
        echo "=========================================="
        echo "Test File: $TEST_FILE"
        echo "Timestamp: $(date)"
        echo "------------------------------------------"
        echo "Total Tests: $total_tests"
        echo "Passed: $passed"
        echo "Failed: $failed"
        echo "Counterexamples Found: $counterexamples"
        echo "=========================================="
    } > "$SUMMARY_FILE"
    
    log_success "Summary saved to: $SUMMARY_FILE"
    
    # Display summary
    cat "$SUMMARY_FILE"
    
    # Check for failures
    if [ "$failed" -gt 0 ] || [ "$counterexamples" -gt 0 ]; then
        log_warning "Some tests failed or counterexamples were found!"
        log_info "Review the full output: $OUTPUT_FILE"
        return 1
    else
        log_success "All equivalence proofs passed!"
        return 0
    fi
}

# Main execution
main() {
    log_info "=========================================="
    log_info "Halmos Equivalence Proof Pipeline"
    log_info "=========================================="
    log_info "Project Root: $PROJECT_ROOT"
    log_info "Test File: $TEST_FILE"
    log_info "=========================================="
    
    # Execute pipeline steps
    if ! build_contracts; then
        log_error "Pipeline failed at build step"
        exit 1
    fi
    
    if ! generate_test_harness; then
        log_warning "Test generation had issues, but continuing..."
    fi
    
    if ! run_halmos; then
        log_error "Pipeline failed at Halmos verification step"
        exit 1
    fi
    
    log_success "=========================================="
    log_success "Pipeline completed successfully!"
    log_success "=========================================="
}

# Run main function
main "$@"

