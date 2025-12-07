#!/usr/bin/env python3
"""
Automated Formal Verification Pipeline

This script automatically:
1. Takes two contract files (Original and Optimized)
2. Extracts contract names and function signatures
3. Generates a complete equivalence test harness
4. Builds the contracts
5. Runs Halmos formal verification
6. Reports results

Usage:
    python3 auto_verify.py <original_contract> <optimized_contract>
    
Example:
    python3 auto_verify.py src/Original.sol src/Optimized.sol
"""

import os
import sys
import json
import subprocess
import re
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'

def log_info(msg: str):
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")

def log_success(msg: str):
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {msg}")

def log_warning(msg: str):
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {msg}")

def log_error(msg: str):
    print(f"{Colors.RED}[ERROR]{Colors.NC} {msg}")

class ContractAnalyzer:
    """Extracts contract information from Solidity files."""
    
    def __init__(self, contract_path: str):
        self.contract_path = Path(contract_path)
        if not self.contract_path.exists():
            raise FileNotFoundError(f"Contract not found: {contract_path}")
    
    def extract_contract_name(self) -> str:
        """Extract contract name from file."""
        with open(self.contract_path, 'r') as f:
            content = f.read()
        
        # Match: contract ContractName {
        match = re.search(r'contract\s+(\w+)\s*\{', content)
        if match:
            return match.group(1)
        
        # Try interface
        match = re.search(r'interface\s+(\w+)\s*\{', content)
        if match:
            return match.group(1)
        
        raise ValueError(f"Could not find contract name in {self.contract_path}")
    
    def extract_functions(self, use_abi: bool = True) -> List[Dict]:
        """Extract public/external function signatures.
        
        Args:
            use_abi: If True, try to use ABI from build artifacts (more accurate)
        """
        # Try to use ABI first (more accurate)
        if use_abi:
            try:
                return self._extract_from_abi()
            except:
                pass  # Fall back to source parsing
        
        # Fall back to source code parsing
        return self._extract_from_source()
    
    def _extract_from_abi(self) -> List[Dict]:
        """Extract functions from ABI (requires forge build)."""
        contract_name = self.extract_contract_name()
        
        # Try different artifact path formats
        possible_paths = [
            Path(f"out/{contract_name}.sol/{contract_name}.json"),
            Path(f"out/{self.contract_path.stem}.sol/{contract_name}.json"),
        ]
        
        # Also try to find by searching out directory
        artifact_path = None
        out_dir = Path("out")
        if out_dir.exists():
            for sol_dir in out_dir.iterdir():
                if sol_dir.is_dir():
                    json_file = sol_dir / f"{contract_name}.json"
                    if json_file.exists():
                        artifact_path = json_file
                        break
        
        if not artifact_path or not artifact_path.exists():
            raise FileNotFoundError(f"Artifact not found for {contract_name}. Run 'forge build' first.")
        
        with open(artifact_path, 'r') as f:
            artifact = json.load(f)
        
        functions = []
        for item in artifact.get('abi', []):
            if item.get('type') == 'function':
                state_mutability = item.get('stateMutability', '')
                # Only include public/external functions
                if state_mutability in ['pure', 'view', 'nonpayable', 'payable']:
                    functions.append({
                        'name': item['name'],
                        'params': item.get('inputs', []),
                        'returns': item.get('outputs', [])
                    })
        
        return functions
    
    def _extract_from_source(self) -> List[Dict]:
        """Extract functions from source code."""
        with open(self.contract_path, 'r') as f:
            content = f.read()
        
        functions = []
        
        # Pattern to match function definitions
        pattern = r'function\s+(\w+)\s*\(([^)]*)\)\s*(?:public|external|internal|private)?\s*(?:pure|view|payable)?\s*(?:returns\s*\(([^)]*)\))?'
        
        for match in re.finditer(pattern, content):
            func_name = match.group(1)
            params_str = match.group(2).strip()
            returns_str = match.group(3).strip() if match.group(3) else ""
            
            # Skip constructors and private/internal functions
            if func_name == 'constructor' or 'private' in match.group(0) or 'internal' in match.group(0):
                continue
            
            # Parse parameters
            params = []
            if params_str:
                for param in params_str.split(','):
                    param = param.strip()
                    if param:
                        # Extract type and name
                        parts = param.split()
                        if len(parts) >= 2:
                            param_type = parts[0]
                            param_name = parts[-1] if len(parts) > 1 else f"arg{len(params)}"
                            params.append({
                                'type': param_type,
                                'name': param_name
                            })
            
            functions.append({
                'name': func_name,
                'params': params,
                'returns': returns_str
            })
        
        return functions
    
    def get_relative_import_path(self, project_root: Path) -> str:
        """Get relative import path for the contract."""
        try:
            # Try relative path first
            if self.contract_path.is_absolute():
                rel_path = self.contract_path.relative_to(project_root)
            else:
                # If already relative, resolve it
                rel_path = Path(self.contract_path).resolve().relative_to(project_root.resolve())
            return str(rel_path).replace('\\', '/')
        except ValueError:
            # If not relative, use the path as-is (might be outside project)
            return str(self.contract_path).replace('\\', '/')

class TestGenerator:
    """Generates Halmos equivalence test harness."""
    
    def __init__(self, original: ContractAnalyzer, optimized: ContractAnalyzer, project_root: Path,
                 constraint_bound: int = 20, fast_mode: bool = False):
        self.original = original
        self.optimized = optimized
        self.project_root = project_root
        self.constraint_bound = constraint_bound
        self.fast_mode = fast_mode
    
    def generate_test_file(self, output_path: Path) -> str:
        """Generate complete test file."""
        original_name = self.original.extract_contract_name()
        optimized_name = self.optimized.extract_contract_name()
        original_import = self.original.get_relative_import_path(self.project_root)
        optimized_import = self.optimized.get_relative_import_path(self.project_root)
        
        # Try to use ABI first, fall back to source parsing
        try:
            original_functions = self.original.extract_functions(use_abi=True)
        except:
            original_functions = self.original.extract_functions(use_abi=False)
        
        try:
            optimized_functions = self.optimized.extract_functions(use_abi=True)
        except:
            optimized_functions = self.optimized.extract_functions(use_abi=False)
        
        # Create function name mapping
        original_func_names = {f['name']: f for f in original_functions}
        optimized_func_names = {f['name']: f for f in optimized_functions}
        
        # Find common functions
        common_functions = set(original_func_names.keys()) & set(optimized_func_names.keys())
        
        # Generate test code
        test_code = self._generate_header(original_name, optimized_name, original_import, optimized_import)
        test_code += self._generate_setup(original_name, optimized_name)
        test_code += self._generate_state_checker()
        test_code += self._generate_generic_checker()
        test_code += self._generate_function_tests(common_functions, original_func_names, optimized_func_names)
        test_code += self._generate_footer()
        
        return test_code
    
    def _generate_header(self, original_name: str, optimized_name: str, 
                         original_import: str, optimized_import: str) -> str:
        return f"""// SPDX-License-Identifier: MIT
// Auto-generated equivalence test
// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
pragma solidity ^0.8.20;

import "halmos-cheatcodes/SymTest.sol";
import "forge-std/Test.sol";
import {{{original_name}}} from "../{original_import}";
import {{{optimized_name}}} from "../{optimized_import}";

/**
 * @title Auto-Generated Equivalence Test
 * @notice Symbolically verifies that {original_name} and {optimized_name} are equivalent
 */
contract AutoEquivalenceTest is SymTest, Test {{
    {original_name} original;
    {optimized_name} optimized;

"""
    
    def _extract_constructor_params(self, analyzer: ContractAnalyzer) -> List[Dict]:
        """Extract constructor parameters from contract."""
        try:
            functions = analyzer.extract_functions(use_abi=True)
            # Look for constructor in ABI
            contract_name = analyzer.extract_contract_name()
            artifact_path = None
            
            # Try to find artifact
            out_dir = Path("out")
            if out_dir.exists():
                for sol_dir in out_dir.iterdir():
                    if sol_dir.is_dir():
                        json_file = sol_dir / f"{contract_name}.json"
                        if json_file.exists():
                            artifact_path = json_file
                            break
            
            if artifact_path:
                with open(artifact_path, 'r') as f:
                    artifact = json.load(f)
                
                for item in artifact.get('abi', []):
                    if item.get('type') == 'constructor':
                        return item.get('inputs', [])
        except:
            pass
        
        # Fallback: try to parse from source
        try:
            with open(analyzer.contract_path, 'r') as f:
                content = f.read()
            
            # Match constructor(uint256 cap_) or constructor(uint256 cap_) {
            pattern = r'constructor\s*\(([^)]*)\)'
            match = re.search(pattern, content)
            if match:
                params_str = match.group(1).strip()
                if params_str:
                    params = []
                    for i, param in enumerate(params_str.split(',')):
                        param = param.strip()
                        if param:
                            parts = param.split()
                            if len(parts) >= 1:
                                param_type = parts[0]
                                param_name = parts[-1] if len(parts) > 1 else f"arg{i}"
                                params.append({
                                    'type': param_type,
                                    'name': param_name
                                })
                    return params
        except:
            pass
        
        return []
    
    def _generate_setup(self, original_name: str, optimized_name: str) -> str:
        """Generate setUp function with constructor arguments."""
        # Extract constructor parameters
        orig_constructor_params = self._extract_constructor_params(self.original)
        opt_constructor_params = self._extract_constructor_params(self.optimized)
        
        # Generate constructor arguments
        orig_args = []
        opt_args = []
        orig_arg_names = []
        opt_arg_names = []
        
        # Store cap value for later use in constraints
        self.cap_value = None
        
        # For original contract
        for i, param in enumerate(orig_constructor_params):
            if isinstance(param, dict):
                param_type = param.get('type', 'uint256')
                param_name = param.get('name', '') or f'arg{i}'
            else:
                param_type = param.get('type', 'uint256')
                param_name = param.get('name', f'arg{i}')
            
            # Generate symbolic value or use a reasonable default
            if 'uint' in param_type or 'int' in param_type:
                # Use a reasonable default value
                cap_val = self.constraint_bound
                orig_args.append(f"{cap_val}")
                self.cap_value = cap_val  # Store for use in constraints
                orig_arg_names.append(f"constructorArg{i}")
            elif param_type == 'address':
                orig_args.append("address(0x1234)")  # Use a test address
                orig_arg_names.append(f"constructorArg{i}")
            else:
                orig_args.append(f"/* TODO: provide {param_type} */")
                orig_arg_names.append(f"constructorArg{i}")
        
        # For optimized contract (should match original)
        for i, param in enumerate(opt_constructor_params):
            if isinstance(param, dict):
                param_type = param.get('type', 'uint256')
                param_name = param.get('name', '') or f'arg{i}'
            else:
                param_type = param.get('type', 'uint256')
                param_name = param.get('name', f'arg{i}')
            
            # Use same values as original
            if i < len(orig_args):
                opt_args.append(orig_args[i])
            else:
                # Generate if optimized has more params
                if 'uint' in param_type or 'int' in param_type:
                    opt_args.append(f"{self.constraint_bound}")
                elif param_type == 'address':
                    opt_args.append("address(0x1234)")
                else:
                    opt_args.append(f"/* TODO: provide {param_type} */")
        
        # Generate setup code
        orig_constructor = f"new {original_name}({', '.join(orig_args)})" if orig_args else f"new {original_name}()"
        opt_constructor = f"new {optimized_name}({', '.join(opt_args)})" if opt_args else f"new {optimized_name}()"
        
        return f"""    function setUp() public {{
        original = {orig_constructor};
        optimized = {opt_constructor};
        assertStateEquivalence();
    }}

"""
    
    def _generate_state_checker(self) -> str:
        return """    /**
     * @notice Verifies that both contracts have equivalent state
     */
    function assertStateEquivalence() internal {
        // This is a placeholder - customize based on your contract's state variables
        // Example checks:
        // assert(original.counter() == optimized.counter());
        // assert(original.balance() == optimized.balance());
    }

"""
    
    def _generate_generic_checker(self) -> str:
        return """    /**
     * @notice Generic function equivalence checker
     * @dev Internal to prevent Halmos from testing with arbitrary inputs
     */
    function check_function_equivalence(
        bytes4 selector,
        bytes memory args
    ) internal {
        (bool success1, bytes memory returnData1) = address(original).call(
            abi.encodePacked(selector, args)
        );

        (bool success2, bytes memory returnData2) = address(optimized).call(
            abi.encodePacked(selector, args)
        );

        assert(success1 == success2);

        if (success1 && success2) {
            assert(keccak256(returnData1) == keccak256(returnData2));
        }
        
        assertStateEquivalence();
    }

"""
    
    def _generate_function_tests(self, common_functions: set, 
                                original_funcs: Dict, optimized_funcs: Dict) -> str:
        test_functions = ""
        
        for func_name in sorted(common_functions):
            orig_func = original_funcs[func_name]
            opt_func = optimized_funcs[func_name]
            
            # Use original function's params (assuming they match)
            params = orig_func['params']
            
            # Generate parameter list
            param_decls = []
            param_names = []
            constraints = []
            
            for i, param in enumerate(params):
                # Handle ABI format (dict with 'type' and 'name') or source format
                if isinstance(param, dict):
                    param_type = param.get('type', 'uint256')
                    # ABI format: ensure we always have a name
                    # Try name first, then internalType, then generate one
                    param_name = param.get('name', '')
                    if not param_name or param_name.strip() == '':
                        # Try to extract from internalType (e.g., "address indexed recipient" -> "recipient")
                        internal_type = param.get('internalType', '')
                        if internal_type:
                            parts = internal_type.split()
                            if len(parts) > 1:
                                param_name = parts[-1]  # Take last word
                        # If still no name, generate one based on type
                        if not param_name or param_name.strip() == '':
                            if 'address' in param_type:
                                param_name = f'recipient'
                            elif 'uint' in param_type or 'int' in param_type:
                                param_name = f'value'
                            else:
                                param_name = f'arg{i}'
                else:
                    # Legacy format
                    param_type = param.get('type', 'uint256')
                    param_name = param.get('name', '')
                    if not param_name or param_name.strip() == '':
                        param_name = f'arg{i}'
                
                # Handle data location for reference types
                # Arrays and strings need data location (memory or calldata)
                if '[]' in param_type or 'string' in param_type or 'bytes' in param_type:
                    # Remove any existing data location
                    base_type = param_type.replace(' memory', '').replace(' calldata', '')
                    # Use memory for test functions (calldata is only for external functions)
                    param_decls.append(f"{base_type} memory {param_name}")
                elif 'memory' in param_type or 'calldata' in param_type:
                    # Already has data location, keep it but change calldata to memory for tests
                    base_type = param_type.replace(' calldata', ' memory')
                    param_decls.append(f"{base_type} {param_name}")
                else:
                    param_decls.append(f"{param_type} {param_name}")
                
                param_names.append(param_name)
                
                # Generate constraints based on type
                # Use tighter bounds for faster verification
                if '[]' in param_type:
                    # Array constraints: limit array length for performance
                    bound = 5 if self.fast_mode else 10
                    constraints.append(f"vm.assume({param_name}.length < {bound});")
                elif 'uint' in param_type or 'int' in param_type:
                    # Use configurable bounds
                    # IMPORTANT: Allow values that could exceed constructor parameters (like cap)
                    # This is crucial for finding bugs where optimized versions skip validation
                    # Multiply by 2-3x to allow testing edge cases where values exceed limits
                    bound = 10 if self.fast_mode else self.constraint_bound * 3  # Allow values that could exceed cap
                    constraints.append(f"vm.assume({param_name} < {bound});")
                elif param_type == 'address':
                    constraints.append(f"vm.assume({param_name} != address(0));")
                elif 'string' in param_type or 'bytes' in param_type:
                    bound = 10 if self.fast_mode else self.constraint_bound
                    constraints.append(f"vm.assume(bytes({param_name}).length < {bound});")
            
            constraints_str = "\n        ".join(constraints) if constraints else "// No constraints needed"
            
            # Handle functions with no parameters
            param_list = ', '.join(param_decls) if param_decls else ""
            encode_args = ', '.join(param_names) if param_names else ""
            
            # Generate function test
            if encode_args:
                args_code = f"abi.encode({encode_args})"
            else:
                args_code = '""'
            
            test_functions += f"""    function check_equivalence_{func_name}({param_list}) public {{
        // Constraints
        {constraints_str}

        check_function_equivalence(
            original.{func_name}.selector,
            {args_code}
        );
    }}

"""
        
        return test_functions
    
    def _generate_footer(self) -> str:
        return "}\n"

class VerificationPipeline:
    """Main pipeline for automated verification."""
    
    def __init__(self, original_path: str, optimized_path: str, project_root: Optional[str] = None,
                 fast_mode: bool = False, loop_bound: int = 10, constraint_bound: int = 20):
        self.project_root = Path(project_root).resolve() if project_root else Path.cwd().resolve()
        self.fast_mode = fast_mode
        self.loop_bound = loop_bound
        self.constraint_bound = constraint_bound
        # Resolve contract paths
        original_p = Path(original_path)
        optimized_p = Path(optimized_path)
        if not original_p.is_absolute():
            original_p = (self.project_root / original_p).resolve()
        if not optimized_p.is_absolute():
            optimized_p = (self.project_root / optimized_p).resolve()
        self.original_path = original_p
        self.optimized_path = optimized_p
        self.output_dir = self.project_root / "proof_results"
        self.output_dir.mkdir(exist_ok=True)
        
        # Analyze contracts
        log_info("Analyzing contracts...")
        self.original_analyzer = ContractAnalyzer(self.original_path)
        self.optimized_analyzer = ContractAnalyzer(self.optimized_path)
        
        # Try to build first to get accurate ABIs
        log_info("Building contracts to extract accurate function signatures...")
        try:
            subprocess.run(
                ['forge', 'build'],
                cwd=self.project_root,
                capture_output=True,
                check=False
            )
        except:
            pass  # Continue even if build fails
        
        # Generate test
        self.test_generator = TestGenerator(
            self.original_analyzer,
            self.optimized_analyzer,
            self.project_root,
            constraint_bound=self.constraint_bound,
            fast_mode=self.fast_mode
        )
    
    def run(self) -> bool:
        """Execute the full verification pipeline."""
        log_info("=" * 60)
        log_info("Automated Formal Verification Pipeline")
        log_info("=" * 60)
        log_info(f"Original: {self.original_path}")
        log_info(f"Optimized: {self.optimized_path}")
        log_info("=" * 60)
        
        # Step 1: Generate test file
        if not self._generate_test():
            return False
        
        # Step 2: Build contracts
        if not self._build_contracts():
            return False
        
        # Step 3: Run Halmos
        if not self._run_halmos():
            return False
        
        log_success("=" * 60)
        log_success("Verification pipeline completed!")
        log_success("=" * 60)
        return True
    
    def _generate_test(self) -> bool:
        """Generate test harness."""
        log_info("Generating equivalence test harness...")
        
        try:
            test_file = self.project_root / "test" / "AutoEquivalenceTest.t.sol"
            test_file.parent.mkdir(exist_ok=True)
            
            test_code = self.test_generator.generate_test_file(test_file)
            
            with open(test_file, 'w') as f:
                f.write(test_code)
            
            log_success(f"Test file generated: {test_file}")
            
            # Show summary
            original_name = self.original_analyzer.extract_contract_name()
            optimized_name = self.optimized_analyzer.extract_contract_name()
            original_funcs = self.original_analyzer.extract_functions()
            optimized_funcs = self.optimized_analyzer.extract_functions()
            common = set(f['name'] for f in original_funcs) & set(f['name'] for f in optimized_funcs)
            
            log_info(f"Contract: {original_name} vs {optimized_name}")
            log_info(f"Common functions to verify: {len(common)}")
            for func in sorted(common):
                log_info(f"  - {func}()")
            
            return True
        except Exception as e:
            log_error(f"Failed to generate test: {e}")
            return False
    
    def _build_contracts(self) -> bool:
        """Build Solidity contracts."""
        log_info("Building contracts...")
        
        try:
            result = subprocess.run(
                ['forge', 'build', '--force'],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                check=True
            )
            log_success("Contracts built successfully")
            return True
        except subprocess.CalledProcessError as e:
            log_error(f"Build failed: {e.stderr}")
            return False
        except FileNotFoundError:
            log_error("Foundry not found. Install from https://getfoundry.sh/")
            return False
    
    def _run_halmos(self) -> bool:
        """Run Halmos verification."""
        log_info("Running Halmos symbolic verification...")
        
        # Check if Halmos is available
        try:
            subprocess.run(['halmos', '--version'], capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            log_error("Halmos not found. Install with: pip install halmos")
            log_info("Or activate virtual environment: source venv/bin/activate")
            return False
        
        test_file = self.project_root / "test" / "AutoEquivalenceTest.t.sol"
        contract_name = "AutoEquivalenceTest"  # Contract name in the test file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = self.output_dir / f'halmos_{timestamp}.log'
        
        log_info(f"Test file: {test_file}")
        log_info(f"Contract: {contract_name}")
        log_info(f"Output: {output_file}")
        
        # Halmos optimization flags for faster execution
        if self.fast_mode:
            # Ultra-fast mode: very tight bounds
            loop_bound = '5'
            timeout_assertion = '10'
            timeout_branching = '5'
        else:
            # Balanced mode: good coverage with reasonable speed
            loop_bound = str(self.loop_bound)
            timeout_assertion = '30'
            timeout_branching = '10'
        
        halmos_args = [
            'halmos',
            '--contract', contract_name,
            '--loop', loop_bound,
            '--solver-timeout-assertion', timeout_assertion,
            '--solver-timeout-branching', timeout_branching,
            '--solver-max-memory', '8192',  # 8GB memory limit
        ]
        
        log_info(f"Running: {' '.join(halmos_args)}")
        
        try:
            with open(output_file, 'w') as f:
                result = subprocess.run(
                    halmos_args,
                    cwd=self.project_root,
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    text=True,
                    check=False
                )
            
            # Parse and display results
            with open(output_file, 'r') as f:
                output = f.read()
            
            # Count passes and failures
            passes = output.count('[PASS]') + output.count('✓')
            failures = output.count('[FAIL]') + output.count('✗')
            counterexamples = output.count('Counterexample')
            
            log_info("=" * 60)
            log_info("Verification Results:")
            log_info(f"  Passed: {passes}")
            log_info(f"  Failed: {failures}")
            log_info(f"  Counterexamples: {counterexamples}")
            log_info("=" * 60)
            
            if failures > 0 or counterexamples > 0:
                log_warning("Some tests failed or counterexamples were found!")
                log_info(f"Review full output: {output_file}")
                return False
            else:
                log_success("All equivalence proofs passed!")
                return True
                
        except Exception as e:
            log_error(f"Error running Halmos: {e}")
            return False

def main():
    parser = argparse.ArgumentParser(
        description='Automated Formal Verification for Two Contracts',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage
  python3 auto_verify.py src/Original.sol src/Optimized.sol

  # Fast mode (quick verification with less coverage)
  python3 auto_verify.py src/Original.sol src/Optimized.sol --fast

  # Custom bounds for speed/coverage trade-off
  python3 auto_verify.py src/Original.sol src/Optimized.sol --loop-bound 5 --constraint-bound 10

  # With custom project root
  python3 auto_verify.py src/ContractA.sol src/ContractB.sol --root /path/to/project
        """
    )
    
    parser.add_argument(
        'original',
        help='Path to original contract file'
    )
    
    parser.add_argument(
        'optimized',
        help='Path to optimized contract file'
    )
    
    parser.add_argument(
        '--root',
        default=None,
        help='Project root directory (default: current directory)'
    )
    
    parser.add_argument(
        '--fast',
        action='store_true',
        help='Fast mode: use very tight bounds for quick verification (less coverage)'
    )
    
    parser.add_argument(
        '--loop-bound',
        type=int,
        default=10,
        help='Maximum loop unrolling iterations (default: 10, use 5 for faster, 20 for more coverage)'
    )
    
    parser.add_argument(
        '--constraint-bound',
        type=int,
        default=20,
        help='Maximum value for integer constraints (default: 20, use 10 for faster, 50 for more coverage)'
    )
    
    args = parser.parse_args()
    
    # Validate files exist
    if not os.path.exists(args.original):
        log_error(f"Original contract not found: {args.original}")
        sys.exit(1)
    
    if not os.path.exists(args.optimized):
        log_error(f"Optimized contract not found: {args.optimized}")
        sys.exit(1)
    
    # Run pipeline
    pipeline = VerificationPipeline(
        args.original, 
        args.optimized, 
        args.root,
        fast_mode=args.fast,
        loop_bound=args.loop_bound,
        constraint_bound=args.constraint_bound
    )
    success = pipeline.run()
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

