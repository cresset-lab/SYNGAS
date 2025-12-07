#!/usr/bin/env python3
import os
import json
import time
from pathlib import Path
from llm_optimize_verify import IterativeOptimizer, log_info, Colors

# Configuration
BENCHMARK_DIR = Path("benchmark")
RESULTS_FILE = "agent_experiment_results.json"
MAX_ITERATIONS = 5

def run_agent_experiment():
    results = []
    
    # Define the cases to run (skip if they don't exist)
    test_cases = sorted([d for d in BENCHMARK_DIR.iterdir() if d.is_dir()])
    
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    print(f"{Colors.CYAN}    STARTING AGENTIC OPTIMIZATION RUN     {Colors.NC}")
    print(f"{Colors.CYAN}=========================================={Colors.NC}")

    for case in test_cases:
        case_name = case.name
        original_path = case / "Original.sol"
        
        if not original_path.exists():
            continue

        print(f"\n{Colors.BLUE}>> Optimization Target: {case_name}{Colors.NC}")
        
        start_time = time.time()
        
        # Initialize the Agent
        # Note: Ensure OPENAI_API_KEY is set in your env
        optimizer = IterativeOptimizer(
            str(original_path),
            max_iterations=MAX_ITERATIONS,
            model="gpt-4" # Or "gpt-3.5-turbo" to save cost/test robustness
        )
        
        # Run the Neuro-Symbolic Loop
        # This returns True if it eventually found a verified optimization
        success = optimizer.run()
        elapsed = time.time() - start_time
        
        # We need to know how many iterations it took.
        # We can infer this by checking which files exist in llm_optimized/
        # e.g., if OriginalOpt_iter3.sol exists, it took 3 tries.
        contract_name = optimizer._extract_contract_name(optimizer.original_code)
        opt_name = f"{contract_name}Opt"
        
        iterations_taken = 0
        for i in range(1, MAX_ITERATIONS + 1):
            if (optimizer.output_dir / f"{opt_name}_iter{i}.sol").exists():
                iterations_taken = i
        
        status_symbol = "✅" if success else "❌"
        
        results.append({
            "case": case_name,
            "success": success,
            "iterations": iterations_taken,
            "time": round(elapsed, 2)
        })
        
        print(f"{Colors.YELLOW}Result: {status_symbol} (Iterations: {iterations_taken}){Colors.NC}")

    # --- Generate the "Paper-Ready" Table ---
    print(f"\n{Colors.CYAN}=========================================={Colors.NC}")
    print(f"{Colors.CYAN}         AGENT EXPERIMENT RESULTS         {Colors.NC}")
    print(f"{Colors.CYAN}=========================================={Colors.NC}")
    
    print(f"{'CASE NAME':<30} | {'SUCCESS':<10} | {'ITERS':<10} | {'TIME'}")
    print("-" * 75)
    
    for r in results:
        success_str = "YES" if r['success'] else "NO"
        color = Colors.GREEN if r['success'] else Colors.RED
        print(f"{color}{r['case']:<30} | {success_str:<10} | {r['iterations']:<10} | {r['time']}s{Colors.NC}")

    # Save data for your thesis
    with open(RESULTS_FILE, 'w') as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    if not os.getenv("OPENAI_API_KEY"):
        print(f"{Colors.RED}Error: OPENAI_API_KEY not set.{Colors.NC}")
        exit(1)
    run_agent_experiment()