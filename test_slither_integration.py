#!/usr/bin/env python3
"""
Test script for Slither integration in LLM optimization loop.
Tests on benchmark/06_Reentrancy_Protection/Optimized.sol
"""

import sys
from pathlib import Path
from llm_optimize_verify import run_slither_analysis

def test_slither_on_reentrancy():
    """Test Slither on the reentrancy protection benchmark."""
    print("=" * 70)
    print("Testing Slither Integration")
    print("=" * 70)
    
    # Read the optimized contract (which has the bug)
    optimized_path = Path("benchmark/06_Reentrancy_Protection/Optimized.sol")
    
    if not optimized_path.exists():
        print(f"Error: {optimized_path} not found")
        return False
    
    with open(optimized_path, 'r') as f:
        optimized_code = f.read()
    
    print(f"\nTesting contract: {optimized_path}")
    print("\nContract code:")
    print("-" * 70)
    print(optimized_code)
    print("-" * 70)
    
    # Run Slither analysis
    print("\nRunning Slither analysis...")
    issues = run_slither_analysis(optimized_code)
    
    print(f"\nFound {len(issues)} High/Medium issue(s):")
    if issues:
        for i, issue in enumerate(issues, 1):
            print(f"  {i}. {issue}")
        print("\n✓ Slither successfully detected security issues!")
        return True
    else:
        print("  No High/Medium issues found")
        print("\n⚠ Slither did not detect issues (this might be expected if Slither is not installed)")
        return False

if __name__ == '__main__':
    success = test_slither_on_reentrancy()
    sys.exit(0 if success else 1)

