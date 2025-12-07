#!/usr/bin/env python3
"""
LLM-Based Contract Optimization with Iterative Verification

This script:
1. Takes an original Solidity contract
2. Uses an LLM to generate an optimized version
3. Verifies equivalence using Halmos
4. If verification fails, feeds counterexamples back to the LLM
5. Iterates until verification passes or max iterations reached

Usage:
    python3 llm_optimize_verify.py <original_contract> [--max-iterations N] [--model MODEL]
    
Example:
    python3 llm_optimize_verify.py src/CappedDeposits.sol --max-iterations 5
"""

import os
import sys
import json
import subprocess
import re
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
# Import from auto_verify first
sys.path.insert(0, str(Path(__file__).parent))
from auto_verify import VerificationPipeline, ContractAnalyzer, TestGenerator, log_info, log_success, log_warning, log_error

import dotenv
dotenv.load_dotenv()

# Try to import OpenAI
try:
    import openai
    HAS_OPENAI = True
except ImportError:
    HAS_OPENAI = False
    log_warning("openai package not installed. Install with: pip install openai")

# Color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'

class LLMOptimizer:
    """Uses LLM to optimize Solidity contracts."""
    
    def __init__(self, model: str = "gpt-4", api_key: Optional[str] = None):
        self.model = model
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")
        if not self.api_key or not HAS_OPENAI:
            log_warning("OPENAI_API_KEY not set or openai package missing. Using mock mode.")
            self.mock_mode = True
        else:
            openai.api_key = self.api_key
            self.mock_mode = False
    
    def optimize_contract(self, contract_path: str, original_code: str, 
                         counterexamples: List[Dict] = None, iteration: int = 0) -> str:
        """Generate optimized contract using LLM."""
        
        if self.mock_mode:
            return self._mock_optimize(contract_path, original_code, counterexamples)
        
        # Build prompt
        prompt = self._build_optimization_prompt(original_code, counterexamples, iteration)
        
        try:
            if HAS_OPENAI:
                from openai import OpenAI
                client = OpenAI(api_key=self.api_key)
                response = client.chat.completions.create(
                    model=self.model,
                    messages=[
                        {"role": "system", "content": "You are an expert Solidity optimizer who creates gas-efficient code while maintaining exact functional equivalence."},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.3,
                    max_tokens=2000
                )
                optimized_code = response.choices[0].message.content
            else:
                raise Exception("OpenAI package not available")
            
            # Extract code block if present
            code_match = re.search(r'```solidity\n(.*?)\n```', optimized_code, re.DOTALL)
            if code_match:
                optimized_code = code_match.group(1)
            else:
                # Try without language tag
                code_match = re.search(r'```\n(.*?)\n```', optimized_code, re.DOTALL)
                if code_match:
                    optimized_code = code_match.group(1)
            
            return optimized_code.strip()
            
        except Exception as e:
            log_error(f"LLM API error: {e}")
            if iteration == 0:
                return self._mock_optimize(contract_path, original_code, counterexamples)
            raise
    
    def _build_optimization_prompt(self, original_code: str, 
                                  counterexamples: List[Dict] = None,
                                  iteration: int = 0) -> str:
        """Build prompt for LLM optimization."""
        
        if iteration == 0:
            prompt = f"""Optimize the following Solidity contract for gas efficiency while maintaining EXACT functional equivalence.

Requirements:
1. Maintain identical behavior (same reverts, same return values, same state changes)
2. Apply gas optimizations (unchecked blocks, storage caching, loop optimizations, etc.)
3. Keep the same function signatures and public interface
4. Preserve all security checks and invariants

Original Contract:
```solidity
{original_code}
```

Generate the optimized version. Return ONLY the complete contract code in a code block."""
        else:
            counterexample_text = self._format_counterexamples(counterexamples)
            prompt = f"""The previous optimization introduced a bug. Fix it while maintaining gas optimizations.

Original Contract:
```solidity
{original_code}
```

The optimized version failed equivalence verification with these counterexamples:
{counterexample_text}

Fix the optimization to handle these cases correctly while keeping the gas optimizations.
Return ONLY the complete fixed contract code in a code block."""
        
        return prompt
    
    def _format_counterexamples(self, counterexamples: List[Dict]) -> str:
        """Format counterexamples for LLM prompt."""
        if not counterexamples:
            return "No specific counterexamples provided."
        
        text = "Counterexamples Found:\n"
        for i, ce in enumerate(counterexamples, 1):
            text += f"\n{i}. Function: {ce.get('function', 'unknown')}\n"
            
            # Format input values
            inputs = ce.get('input', {})
            if inputs:
                text += "   Input values:\n"
                for key, val in inputs.items():
                    if isinstance(val, dict):
                        text += f"     {key} = {val.get('decimal', val.get('hex', val))} (decimal: {val.get('decimal', 'N/A')})\n"
                    else:
                        text += f"     {key} = {val}\n"
            
            text += f"   Issue: {ce.get('issue', 'Behavior differs from original')}\n"
            if ce.get('original_behavior'):
                text += f"   Original behavior: {ce['original_behavior']}\n"
            if ce.get('optimized_behavior'):
                text += f"   Optimized behavior: {ce['optimized_behavior']}\n"
            
            # Add specific guidance
            if 'deposit' in ce.get('function', '').lower():
                if 'amount' in inputs:
                    amount = inputs['amount']
                    if isinstance(amount, dict):
                        amount = amount.get('decimal', amount.get('hex', amount))
                    text += f"\n   Analysis: The deposit function fails when amount = {amount}.\n"
                    text += "   The optimized version likely removed a validation check (like cap enforcement).\n"
        
        return text
    
    def _mock_optimize(self, contract_path: str, original_code: str, 
                      counterexamples: List[Dict] = None) -> str:
        """Mock optimizer for testing without API key."""
        log_warning("Using mock optimizer (no API key). This will create a simple optimized version.")
        
        # Simple mock: just add unchecked blocks (intentionally buggy for testing)
        optimized = original_code.replace(
            "deposits[msg.sender] = newBalance;",
            "unchecked { deposits[msg.sender] += amount; }"
        )
        
        return optimized

class CounterexampleParser:
    """Parses counterexamples from Halmos output."""
    
    @staticmethod
    def parse_halmos_log(log_file: str) -> Tuple[List[Dict], bool]:
        """Parse Halmos log file for counterexamples."""
        counterexamples = []
        all_passed = True
        
        try:
            with open(log_file, 'r') as f:
                content = f.read()
            
            # Check if all tests passed
            if '[FAIL]' in content or 'Counterexample' in content:
                all_passed = False
            
            # Extract failed function names with their counterexamples
            # Pattern: [FAIL] function_name(...) followed by Counterexample
            fail_sections = re.split(r'\[FAIL\]\s+(\w+)\([^)]*\)', content)
            
            for i in range(1, len(fail_sections), 2):
                if i + 1 < len(fail_sections):
                    func_name = fail_sections[i]
                    section = fail_sections[i + 1]
                    
                    ce = {
                        'function': func_name,
                        'input': {},
                        'issue': 'Behavior differs from original contract',
                        'original_behavior': 'Reverted or returned different value',
                        'optimized_behavior': 'Succeeded or returned different value'
                    }
                    
                    # Extract counterexample values
                    ce_match = re.search(r'Counterexample:\s*\n\s*((?:[^\n]+=.*\n?)+)', section)
                    if ce_match:
                        lines = ce_match.group(1).strip().split('\n')
                        for line in lines:
                            line = line.strip()
                            if '=' in line:
                                parts = line.split('=')
                                if len(parts) == 2:
                                    var = parts[0].strip()
                                    val = parts[1].strip()
                                    
                                    # Clean up variable name
                                    var = re.sub(r'p_\w+_\w+_\d+', '', var).strip()
                                    
                                    # Convert hex to decimal if possible
                                    if val.startswith('0x'):
                                        try:
                                            dec_val = int(val, 16)
                                            ce['input'][var] = {
                                                'hex': val,
                                                'decimal': str(dec_val)
                                            }
                                        except:
                                            ce['input'][var] = val
                                    else:
                                        ce['input'][var] = val
                    
                    # Try to infer parameter names from function signature
                    # For deposit(uint256 amount), look for uint256 values
                    if 'deposit' in func_name.lower() and 'amount' not in str(ce['input']):
                        for key, val in ce['input'].items():
                            if isinstance(val, dict) and 'decimal' in val:
                                ce['input']['amount'] = val['decimal']
                                break
                    
                    counterexamples.append(ce)
            
        except Exception as e:
            log_warning(f"Error parsing counterexamples: {e}")
            import traceback
            traceback.print_exc()
        
        return counterexamples, all_passed

class IterativeOptimizer:
    """Main class for iterative optimization and verification."""
    
    def __init__(self, original_path: str, max_iterations: int = 5, 
                 model: str = "gpt-4", api_key: Optional[str] = None):
        self.original_path = Path(original_path)
        self.max_iterations = max_iterations
        self.project_root = Path.cwd()
        self.output_dir = self.project_root / "llm_optimized"
        self.output_dir.mkdir(exist_ok=True)
        
        self.llm = LLMOptimizer(model=model, api_key=api_key)
        self.parser = CounterexampleParser()
        
        # Read original contract
        with open(self.original_path, 'r') as f:
            self.original_code = f.read()
    
    def run(self) -> bool:
        """Run iterative optimization and verification."""
        log_info("=" * 70)
        log_info("LLM-Based Iterative Contract Optimization")
        log_info("=" * 70)
        log_info(f"Original: {self.original_path}")
        log_info(f"Max iterations: {self.max_iterations}")
        log_info("=" * 70)
        
        optimized_path = None
        counterexamples = []
        
        for iteration in range(self.max_iterations):
            log_info(f"\n{'='*70}")
            log_info(f"Iteration {iteration + 1}/{self.max_iterations}")
            log_info(f"{'='*70}")
            
            # Step 1: Generate optimized contract
            if iteration == 0:
                log_info("Generating initial optimized version...")
            else:
                log_info(f"Fixing optimization based on {len(counterexamples)} counterexample(s)...")
            
            try:
                optimized_code = self.llm.optimize_contract(
                    str(self.original_path),
                    self.original_code,
                    counterexamples,
                    iteration
                )
            except Exception as e:
                log_error(f"Failed to generate optimization: {e}")
                return False
            
            # Step 2: Save optimized contract
            contract_name = self._extract_contract_name(self.original_code)
            optimized_name = f"{contract_name}Opt"
            optimized_path = self.output_dir / f"{optimized_name}_iter{iteration + 1}.sol"
            
            # Update contract name in code
            optimized_code = optimized_code.replace(
                f"contract {contract_name}",
                f"contract {optimized_name}",
                1
            )
            
            with open(optimized_path, 'w') as f:
                f.write(optimized_code)
            
            log_success(f"Optimized contract saved: {optimized_path}")
            
            # Step 3: Verify equivalence
            log_info("Running equivalence verification...")
            pipeline = VerificationPipeline(
                str(self.original_path),
                str(optimized_path),
                str(self.project_root)
            )
            
            # Generate test and build
            if not pipeline._generate_test():
                log_error("Failed to generate test")
                continue
            
            if not pipeline._build_contracts():
                log_error("Failed to build contracts")
                continue
            
            # Run Halmos verification
            success = False
            log_file = None
            
            try:
                # Check if Halmos is available
                subprocess.run(['halmos', '--version'], capture_output=True, check=True)
                
                test_file = pipeline.project_root / "test" / "AutoEquivalenceTest.t.sol"
                contract_name = "AutoEquivalenceTest"
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                output_file = pipeline.output_dir / f'halmos_iter{iteration + 1}_{timestamp}.log'
                
                # Run Halmos with optimization flags
                if pipeline.fast_mode:
                    loop_bound = '5'
                    timeout_assertion = '10'
                    timeout_branching = '5'
                else:
                    loop_bound = str(pipeline.loop_bound)
                    timeout_assertion = '30'
                    timeout_branching = '10'
                
                halmos_args = [
                    'halmos',
                    '--contract', contract_name,
                    '--loop', loop_bound,
                    '--solver-timeout-assertion', timeout_assertion,
                    '--solver-timeout-branching', timeout_branching,
                    '--solver-max-memory', '8192',
                ]
                
                log_info(f"Running: {' '.join(halmos_args)}")
                
                with open(output_file, 'w') as f:
                    result = subprocess.run(
                        halmos_args,
                        cwd=pipeline.project_root,
                        stdout=f,
                        stderr=subprocess.STDOUT,
                        text=True,
                        check=False
                    )
                
                log_file = str(output_file)
                
                # Parse results
                with open(output_file, 'r') as f:
                    output = f.read()
                
                passes = output.count('[PASS]') + output.count('✓')
                failures = output.count('[FAIL]') + output.count('✗')
                counterexample_count = output.count('Counterexample')
                
                log_info("=" * 70)
                log_info("Verification Results:")
                log_info(f"  Passed: {passes}")
                log_info(f"  Failed: {failures}")
                log_info(f"  Counterexamples: {counterexample_count}")
                log_info("=" * 70)
                
                success = (failures == 0 and counterexample_count == 0 and passes > 0)
                
            except FileNotFoundError:
                log_error("Halmos not found. Install with: pip install halmos")
                log_info("Or activate virtual environment: source venv/bin/activate")
                continue
            except Exception as e:
                log_error(f"Error running Halmos: {e}")
                continue
            
            if success:
                log_success("=" * 70)
                log_success("✅ VERIFICATION PASSED!")
                log_success("=" * 70)
                log_success(f"Optimized contract is equivalent to original!")
                log_success(f"Final version: {optimized_path}")
                return True
            
            # Step 4: Parse counterexamples
            if log_file:
                counterexamples, _ = self.parser.parse_halmos_log(log_file)
                log_warning(f"Verification failed. Found {len(counterexamples)} counterexample(s).")
                
                # Print counterexamples
                for i, ce in enumerate(counterexamples, 1):
                    log_info(f"\nCounterexample {i}:")
                    log_info(f"  Function: {ce.get('function', 'unknown')}")
                    if ce.get('input'):
                        log_info(f"  Input: {ce['input']}")
                    log_info(f"  Issue: {ce.get('issue', 'Behavior differs')}")
            
            # Continue to next iteration
            if iteration < self.max_iterations - 1:
                log_info(f"\nAttempting to fix issues and retry...")
        
        # Max iterations reached
        log_error("=" * 70)
        log_error("❌ MAX ITERATIONS REACHED")
        log_error("=" * 70)
        log_error("Could not find an equivalent optimization after {self.max_iterations} iterations.")
        if optimized_path:
            log_info(f"Last attempt: {optimized_path}")
        
        return False
    
    def _extract_contract_name(self, code: str) -> str:
        """Extract contract name from code."""
        match = re.search(r'contract\s+(\w+)\s*\{', code)
        if match:
            return match.group(1)
        return "Contract"

def main():
    parser = argparse.ArgumentParser(
        description='LLM-Based Iterative Contract Optimization with Verification',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage
  python3 llm_optimize_verify.py src/CappedDeposits.sol

  # With custom settings
  python3 llm_optimize_verify.py src/CappedDeposits.sol --max-iterations 10 --model gpt-4

  # Set API key via environment variable
  export OPENAI_API_KEY=your_key_here
  python3 llm_optimize_verify.py src/CappedDeposits.sol
        """
    )
    
    parser.add_argument(
        'contract',
        help='Path to original Solidity contract file'
    )
    
    parser.add_argument(
        '--max-iterations',
        type=int,
        default=5,
        help='Maximum number of optimization iterations (default: 5)'
    )
    
    parser.add_argument(
        '--model',
        default='gpt-4',
        help='LLM model to use (default: gpt-4)'
    )
    
    parser.add_argument(
        '--api-key',
        default=None,
        help='OpenAI API key (or set OPENAI_API_KEY env var)'
    )
    
    args = parser.parse_args()
    
    # Validate contract exists
    if not os.path.exists(args.contract):
        log_error(f"Contract not found: {args.contract}")
        sys.exit(1)
    
    # Run iterative optimization
    optimizer = IterativeOptimizer(
        args.contract,
        max_iterations=args.max_iterations,
        model=args.model,
        api_key=args.api_key or os.getenv("OPENAI_API_KEY")
    )
    
    success = optimizer.run()
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

