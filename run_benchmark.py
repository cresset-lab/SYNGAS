#!/usr/bin/env python3
import os
import sys
import time
import json
from pathlib import Path
from auto_verify import VerificationPipeline, log_info, log_success, log_error, Colors

# Configuration
BENCHMARK_DIR = Path("benchmark")
RESULTS_FILE = "benchmark_results.json"

def run_benchmark():
    results = []
    
    if not BENCHMARK_DIR.exists():
        log_error(f"Benchmark directory '{BENCHMARK_DIR}' not found.")
        return

    # Find all subdirectories
    test_cases = [f for f in BENCHMARK_DIR.iterdir() if f.is_dir()]
    test_cases.sort()

    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    print(f"{Colors.CYAN}    STARTING GAS OPTIMIZATION BENCHMARK   {Colors.NC}")
    print(f"{Colors.CYAN}=========================================={Colors.NC}")

    for case in test_cases:
        case_name = case.name
        original_path = case / "Original.sol"
        optimized_path = case / "Optimized.sol"

        if not original_path.exists() or not optimized_path.exists():
            continue

        print(f"\n{Colors.BLUE}>> Running Case: {case_name}{Colors.NC}")
        
        start_time = time.time()
        
        # Initialize your existing pipeline
        # Cases that should FAIL verification (have bugs):
        bug_cases = [
            "Safety_Trap", "Reentrancy_Protection", "Access_Control",
            "Return_Value", "Zero_Address_Check", "Overflow_Protection",
            "Multiple_Functions", "Constructor_Params", "Bounds_Check",
            "Time_Validation", "Complex_State", "Modifier_Chain",
            "Arithmetic_Precision", "Enum_Validation", "Mapping_Bounds",
            "State_Machine", "Overflow_Edge", "Inheritance_Override",
            "Payable_Check", "Division_Precision", "Nested_Struct",
            "Cross_Function", "Range_Validation", "String_Length",
            "Modulo_Operation", "Array_Manipulation", "Complex_Access",
            "Invariant_Break"
        ]
        expect_failure = any(bug in case_name for bug in bug_cases)
        
        pipeline = VerificationPipeline(
            str(original_path),
            str(optimized_path),
            fast_mode=True, # Use fast mode for benchmarking
            loop_bound=5    # Reasonable bound for proofs
        )
        
        # Capture Success/Fail
        success = pipeline.run()
        elapsed = time.time() - start_time

        # Determine Benchmark Pass/Fail
        # A benchmark passes if:
        # 1. It verifies successfully AND we expected it to pass
        # 2. It FAILS verification AND we expected it to fail (Bug detection)
        benchmark_passed = (success and not expect_failure) or (not success and expect_failure)
        
        status_symbol = "✅" if benchmark_passed else "❌"
        
        results.append({
            "case": case_name,
            "verification_passed": success,
            "expected_pass": not expect_failure,
            "benchmark_result": "PASS" if benchmark_passed else "FAIL",
            "time": round(elapsed, 2)
        })

        print(f"{Colors.YELLOW}Result: {status_symbol} (Time: {elapsed:.2f}s){Colors.NC}")

    # Generate Report
    print(f"\n{Colors.CYAN}=========================================={Colors.NC}")
    print(f"{Colors.CYAN}           BENCHMARK SUMMARY              {Colors.NC}")
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    
    print(f"{'CASE NAME':<30} | {'VERIFIED':<10} | {'EXPECTED':<10} | {'RESULT':<10} | {'TIME'}")
    print("-" * 80)
    
    passed_count = 0
    for r in results:
        if r['benchmark_result'] == "PASS":
            passed_count += 1
        
        ver_str = "YES" if r['verification_passed'] else "NO"
        exp_str = "YES" if r['expected_pass'] else "NO"
        res_str = r['benchmark_result']
        
        color = Colors.GREEN if r['benchmark_result'] == "PASS" else Colors.RED
        print(f"{color}{r['case']:<30} | {ver_str:<10} | {exp_str:<10} | {res_str:<10} | {r['time']}s{Colors.NC}")

    print("-" * 80)
    print(f"Total Score: {passed_count}/{len(results)}")
    
    # Save to JSON
    with open(RESULTS_FILE, 'w') as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    run_benchmark()