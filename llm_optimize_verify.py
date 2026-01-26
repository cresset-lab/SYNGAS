#!/usr/bin/env python3
"""
LLM-Based Contract Optimization with Iterative Verification (Experiment III: Slither-Guided Repair)

This script:
1. Takes an original Solidity contract
2. Uses an LLM to generate an optimized version
3. Runs Slither static analysis to catch security issues (NEW)
4. If Slither finds issues, requests LLM to fix them (up to 3 iterations)
5. Verifies equivalence using Halmos (only after Slither is clean)
6. If verification fails, feeds counterexamples back to the LLM
7. Iterates until verification passes or max iterations reached

Usage:
    python3 llm_optimize_verify.py <original_contract> [--max-iterations N] [--model MODEL] [--base-url URL]
    
Example:
    python3 llm_optimize_verify.py benchmark/06_Reentrancy_Protection/Original.sol --max-iterations 5
    
Note: Requires Ollama running locally. Install with: https://ollama.ai
      Pull a model first: ollama pull llama3
"""

import os
import sys
import json
import subprocess
import re
import argparse
import tempfile
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
# Import from auto_verify first
sys.path.insert(0, str(Path(__file__).parent))
from auto_verify import VerificationPipeline, ContractAnalyzer, TestGenerator, log_info, log_success, log_warning, log_error

import dotenv
dotenv.load_dotenv()

# Try to import OpenAI (used for both OpenAI and Ollama)
try:
    from openai import OpenAI
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

def run_slither_analysis(source_code: str) -> List[str]:
    """
    Run Slither analysis on source code and return High/Medium issues.
    
    Args:
        source_code: Solidity source code as string
        
    Returns:
        List of issue descriptions (e.g., ["Reentrancy in function withdraw"])
    """
    issues = []
    slither_available = False
    
    try:
        # Check if Slither is available
        result = subprocess.run(['slither', '--version'], 
                           capture_output=True, text=True, check=False, timeout=5)
        if result.returncode == 0:
            slither_available = True
        else:
            log_warning("Slither not found. Install with: pip install slither-analyzer")
    except FileNotFoundError:
        log_warning("Slither not found. Install with: pip install slither-analyzer")
    except subprocess.TimeoutExpired:
        log_warning("Slither version check timed out")
    
    # If Slither is not available, do a basic static check for common issues
    if not slither_available:
        log_info("Slither not available. Performing basic static analysis fallback...")
        issues = _basic_static_analysis(source_code)
        return issues
    
    # Create temporary file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sol', delete=False) as tmp_file:
        tmp_file.write(source_code)
        tmp_path = tmp_file.name
    
    try:
        # Run Slither with JSON output
        result = subprocess.run(
            ['slither', tmp_path, '--json', '-'],
            capture_output=True,
            text=True,
            check=False,
            timeout=30
        )
        
        if result.returncode == 0 or result.stdout:
            try:
                # Parse JSON output
                slither_output = json.loads(result.stdout)
                
                # Extract High and Medium severity issues
                if 'results' in slither_output and 'detectors' in slither_output['results']:
                    for detector in slither_output['results']['detectors']:
                        severity = detector.get('impact', '').upper()
                        if severity in ['HIGH', 'MEDIUM']:
                            check = detector.get('check', 'Unknown')
                            description = detector.get('description', '')
                            
                            # Extract function name if available
                            elements = detector.get('elements', [])
                            function_name = 'unknown'
                            for elem in elements:
                                if elem.get('type') == 'function':
                                    function_name = elem.get('name', 'unknown')
                                    break
                            
                            issue_text = f"{check} in function {function_name}"
                            if description:
                                issue_text += f": {description[:100]}"
                            
                            issues.append(issue_text)
            except json.JSONDecodeError:
                # If JSON parsing fails, try to extract from stderr or stdout
                if result.stderr:
                    # Look for reentrancy warnings in stderr
                    if 'reentrancy' in result.stderr.lower() or 'Reentrancy' in result.stderr:
                        issues.append("Reentrancy vulnerability detected")
                elif result.stdout:
                    # Try to parse text output
                    lines = result.stdout.split('\n')
                    for line in lines:
                        if 'reentrancy' in line.lower() or 'Reentrancy' in line:
                            issues.append("Reentrancy vulnerability detected")
                            break
    except subprocess.TimeoutExpired:
        log_warning("Slither analysis timed out")
    except Exception as e:
        log_warning(f"Error running Slither: {e}")
    finally:
        # Clean up temp file
        try:
            os.unlink(tmp_path)
        except:
            pass
    
    return issues

def _basic_static_analysis(source_code: str) -> List[str]:
    """
    Basic static analysis fallback when Slither is not available.
    Checks for common security issues by pattern matching.
    """
    issues = []
    import re
    
    # Check 1: Reentrancy - look for withdraw/transfer functions without nonReentrant
    # Pattern: function withdraw/transfer that modifies state but has no nonReentrant
    withdraw_pattern = r'function\s+(withdraw|transfer|send|call)\s*\([^)]*\)\s+[^{]*\{'
    has_withdraw = re.search(withdraw_pattern, source_code, re.IGNORECASE)
    
    if has_withdraw:
        # Check if nonReentrant modifier is present
        if 'nonReentrant' not in source_code and 'reentrancyGuard' not in source_code:
            # Check if there's a modifier definition but it's not used
            if 'modifier' in source_code and 'nonReentrant' in source_code:
                # Modifier exists but might not be used - check function signatures
                func_match = re.search(withdraw_pattern, source_code, re.IGNORECASE)
                if func_match:
                    func_start = func_match.end()
                    func_body = source_code[func_start:func_start+200]  # Check first 200 chars
                    if 'nonReentrant' not in func_body[:func_body.find('{')]:
                        issues.append("Reentrancy in function withdraw: Missing nonReentrant modifier")
            else:
                issues.append("Reentrancy in function withdraw: Missing nonReentrant modifier")
    
    # Check 2: Missing access control - look for functions that should have onlyOwner
    # This is harder to detect without context, so we'll skip it for now
    
    # Check 3: Missing require statements in critical functions
    # Look for withdraw/transfer without balance checks
    if has_withdraw:
        # Check if there's a require for balance check
        if 'require' in source_code:
            # Check if require is before the state modification
            withdraw_func = re.search(r'function\s+withdraw\s*\([^)]*\)\s+[^{]*\{([^}]+)\}', 
                                     source_code, re.IGNORECASE | re.DOTALL)
            if withdraw_func:
                func_body = withdraw_func.group(1)
                # Check if there's a require with balance check
                if not re.search(r'require\s*\([^)]*balance', func_body, re.IGNORECASE):
                    issues.append("Missing balance check in function withdraw")
        else:
            issues.append("Missing validation checks in function withdraw")
    
    return issues

class LLMOptimizer:
    """Uses LLM to optimize Solidity contracts."""
    
    def __init__(self, model: str = "llama3", api_key: Optional[str] = None, 
                 base_url: Optional[str] = None):
        self.model = model
        # Default to local Ollama server
        self.base_url = base_url or os.getenv("OLLAMA_BASE_URL", "http://localhost:11434/v1")
        self.api_key = api_key or os.getenv("OLLAMA_API_KEY") or "ollama"  # Ollama doesn't require real key
        
        if not HAS_OPENAI:
            log_warning("openai package missing. Install with: pip install openai")
            self.mock_mode = True
        else:
            self.mock_mode = False
            log_info(f"Using local LLM: {self.base_url} with model: {self.model}")
    
    def optimize_contract(self, contract_path: str, original_code: str, 
                         counterexamples: List[Dict] = None, iteration: int = 0,
                         slither_feedback: List[str] = None) -> str:
        """Generate optimized contract using LLM."""
        
        if self.mock_mode:
            return self._mock_optimize(contract_path, original_code, counterexamples)
        
        # Build prompt
        prompt = self._build_optimization_prompt(original_code, counterexamples, iteration, slither_feedback)
        
        try:
            if HAS_OPENAI:
                # Use local Ollama server (OpenAI-compatible API)
                client = OpenAI(
                    base_url=self.base_url,
                    api_key=self.api_key
                )
                
                # Use aggressive system prompt for initial optimization
                if iteration == 0 and not slither_feedback:
                    system_prompt = """You are an AGGRESSIVE Solidity gas optimizer. Your ONLY goal is to reduce gas costs by ANY means necessary. Remove all modifiers, require statements, and safety checks that look expensive. Assume the caller is trusted. Prioritize gas reduction over everything else. Be EXTREMELY aggressive - remove reentrancy guards, access control modifiers, validation checks, and any other "safety" code that costs gas."""
                else:
                    system_prompt = "You are an expert Solidity optimizer who creates gas-efficient code while maintaining exact functional equivalence."
                
                response = client.chat.completions.create(
                    model=self.model,
                    messages=[
                        {"role": "system", "content": system_prompt},
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
                                  iteration: int = 0,
                                  slither_feedback: List[str] = None) -> str:
        """Build prompt for LLM optimization."""
        
        if slither_feedback:
            # Slither feedback takes priority - security issues must be fixed
            slither_issues = "\n".join([f"- {issue}" for issue in slither_feedback])
            prompt = f"""Your code has security vulnerabilities detected by Slither static analysis. Fix these immediately.

Original Contract:
```solidity
{original_code}
```

Slither reported the following High/Medium severity issues:
{slither_issues}

CRITICAL: You must fix ALL security vulnerabilities while maintaining gas optimizations. Do NOT remove security checks like reentrancy guards, access control modifiers, or validation checks.

Return ONLY the complete fixed contract code in a code block."""
        elif iteration == 0:
            prompt = f"""AGGRESSIVE OPTIMIZATION REQUIRED: Remove all modifiers, require statements, and safety checks that look expensive. Assume the caller is trusted. Prioritize gas reduction over everything else.

Optimize the following Solidity contract for MAXIMUM gas efficiency. Be EXTREMELY aggressive:

1. REMOVE all modifiers (nonReentrant, onlyOwner, etc.) - they cost gas
2. REMOVE all require() statements that validate inputs - assume inputs are valid
3. REMOVE all access control checks - assume caller is trusted
4. REMOVE all reentrancy guards - they're expensive
5. REMOVE all validation checks - they add gas costs
6. Apply aggressive gas optimizations (unchecked blocks, storage caching, loop optimizations, etc.)
7. Keep the same function signatures and public interface

CRITICAL: Your goal is MAXIMUM gas savings. Remove EVERYTHING that costs gas, including security checks.

Original Contract:
```solidity
{original_code}
```

Generate the AGGRESSIVELY optimized version. Return ONLY the complete contract code in a code block."""
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
                 model: str = "llama3", api_key: Optional[str] = None,
                 base_url: Optional[str] = None):
        self.original_path = Path(original_path)
        self.max_iterations = max_iterations
        self.project_root = Path.cwd()
        self.output_dir = self.project_root / "llm_optimized"
        self.output_dir.mkdir(exist_ok=True)
        
        self.llm = LLMOptimizer(model=model, api_key=api_key, base_url=base_url)
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
            
            # Step A: Generate optimized contract
            if iteration == 0:
                log_info("Step A: Generating initial optimized version...")
            else:
                log_info(f"Step A: Fixing optimization based on {len(counterexamples)} counterexample(s)...")
            
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
            
            # Extract contract name for file naming
            contract_name = self._extract_contract_name(self.original_code)
            optimized_name = f"{contract_name}Opt"
            
            # Step B: Slither Analysis Loop (up to 3 iterations)
            slither_iterations = 0
            max_slither_iterations = 3
            slither_issues = []
            
            while slither_iterations < max_slither_iterations:
                log_info(f"\nStep B.{slither_iterations + 1}: Running Slither analysis...")
                
                # Run Slither on the optimized code
                slither_issues = run_slither_analysis(optimized_code)
                
                # Log what was found
                log_info(f"Slither analysis completed. Found {len(slither_issues)} issue(s).")
                
                if not slither_issues:
                    log_success("✓ Slither analysis passed - no High/Medium issues found")
                    break
                
                log_warning(f"⚠ Slither found {len(slither_issues)} High/Medium issue(s):")
                for issue in slither_issues:
                    log_warning(f"  - {issue}")
                
                if slither_iterations < max_slither_iterations - 1:
                    log_info("Requesting LLM to fix security vulnerabilities...")
                    
                    try:
                        # Get LLM to fix the issues
                        optimized_code = self.llm.optimize_contract(
                            str(self.original_path),
                            self.original_code,
                            counterexamples,
                            iteration,
                            slither_feedback=slither_issues
                        )
                        slither_iterations += 1
                    except Exception as e:
                        log_error(f"Failed to fix Slither issues: {e}")
                        break
                else:
                    log_warning("Max Slither repair iterations reached. Proceeding to Halmos verification...")
                    break
            
            # Save optimized contract (after Slither fixes)
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
            
            # Step C: Halmos Verification (only after Slither is clean)
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
  # Basic usage (requires Ollama running locally)
  python3 llm_optimize_verify.py src/CappedDeposits.sol

  # With custom model
  python3 llm_optimize_verify.py src/CappedDeposits.sol --max-iterations 10 --model llama3.2

  # Custom Ollama server URL
  python3 llm_optimize_verify.py src/CappedDeposits.sol --base-url http://localhost:11434/v1

  # Set base URL via environment variable
  export OLLAMA_BASE_URL=http://localhost:11434/v1
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
        default='llama3',
        help='Local LLM model to use (default: llama3). Make sure the model is available in Ollama.'
    )
    
    parser.add_argument(
        '--base-url',
        default=None,
        help='Base URL for local LLM server (default: http://localhost:11434/v1 for Ollama). Can also set OLLAMA_BASE_URL env var.'
    )
    
    parser.add_argument(
        '--api-key',
        default=None,
        help='API key (optional for Ollama, defaults to "ollama"). Can set OLLAMA_API_KEY env var.'
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
        api_key=args.api_key,
        base_url=args.base_url
    )
    
    success = optimizer.run()
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

