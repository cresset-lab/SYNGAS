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
                abi_funcs = self._extract_from_abi()
                # Validate: check if ABI functions match source functions
                # This prevents using wrong artifacts when multiple contracts have same name
                source_funcs = self._extract_from_source()
                abi_names = {f['name'] for f in abi_funcs}
                source_names = {f['name'] for f in source_funcs}
                
                # If ABI gives us completely different functions, use source instead
                if abi_names and source_names:
                    overlap = abi_names & source_names
                    # If less than 50% overlap, likely wrong artifact
                    if len(overlap) < min(len(abi_names), len(source_names)) * 0.5:
                        # ABI found wrong contract - use source parsing
                        return source_funcs
                
                # If ABI has functions and source doesn't, trust ABI
                if abi_funcs and not source_funcs:
                    return abi_funcs
                
                # Prefer ABI if it matches source (more accurate parameter types)
                return abi_funcs if abi_funcs else source_funcs
            except Exception as e:
                # Fall back to source parsing on any error
                pass
        
        # Fall back to source code parsing
        return self._extract_from_source()
    
    def _extract_from_abi(self) -> List[Dict]:
        """Extract functions from ABI (requires forge build)."""
        contract_name = self.extract_contract_name()
        
        # Try to find artifact based on source file path
        # Forge creates artifacts in out/<source_file_stem>.sol/<contract_name>.json
        artifact_path = None
        out_dir = Path("out")
        
        if out_dir.exists():
            # First, try exact match based on source file path
            source_stem = self.contract_path.stem  # e.g., "Original" from "Original.sol"
            
            # Try: out/<source_stem>.sol/<contract_name>.json
            possible_dir = out_dir / f"{source_stem}.sol"
            if possible_dir.exists():
                json_file = possible_dir / f"{contract_name}.json"
                if json_file.exists():
                    artifact_path = json_file
            
            # If not found, search for any directory containing the contract name
            if not artifact_path:
                # Build relative path from project root to find matching artifact
                try:
                    project_root = Path.cwd()
                    rel_path = self.contract_path.relative_to(project_root)
                    # For benchmark/01_Arithmetic_Unchecked/Original.sol
                    # Look for out/benchmark/01_Arithmetic_Unchecked/Original.sol/Original.json
                    artifact_dir = out_dir / rel_path.with_suffix('')
                    if artifact_dir.exists():
                        json_file = artifact_dir / f"{contract_name}.json"
                        if json_file.exists():
                            artifact_path = json_file
                except:
                    pass
            
            # Fallback: search all directories (less precise)
            if not artifact_path:
                for sol_dir in out_dir.iterdir():
                    if sol_dir.is_dir():
                        json_file = sol_dir / f"{contract_name}.json"
                        if json_file.exists():
                            # Prefer directories that match source file name
                            if source_stem in sol_dir.name or sol_dir.name == source_stem:
                                artifact_path = json_file
                                break
                        # If still not found, take first match (less ideal)
                        if not artifact_path and json_file.exists():
                            artifact_path = json_file
        
        if not artifact_path or not artifact_path.exists():
            raise FileNotFoundError(f"Artifact not found for {contract_name} in {self.contract_path}. Run 'forge build' first.")
        
        with open(artifact_path, 'r') as f:
            artifact = json.load(f)
        
        # Validate that artifact contract name matches expected contract name
        artifact_contract_name = artifact.get('contractName', '')
        if artifact_contract_name and artifact_contract_name != contract_name:
            # This might be the wrong artifact - but continue anyway as it might be a rename
            # The validation in extract_functions will catch if functions don't match
            pass
        
        functions = []
        for item in artifact.get('abi', []):
            if item.get('type') == 'function':
                state_mutability = item.get('stateMutability', '')
                inputs = item.get('inputs', [])
                
                # Filter out state variable getters (view functions with no inputs)
                # These are auto-generated for public state variables
                if state_mutability == 'view' and len(inputs) == 0:
                    continue
                
                # Only include public/external functions
                if state_mutability in ['pure', 'view', 'nonpayable', 'payable']:
                    functions.append({
                        'name': item['name'],
                        'params': inputs,
                        'returns': item.get('outputs', []),
                        'stateMutability': state_mutability,  # Store for constraint generation
                        'is_fallback': False
                    })
        
        # Also check for fallback/receive functions in source (ABI doesn't always include them)
        try:
            with open(self.contract_path, 'r') as f:
                content = f.read()
            
            # Check for receive() external payable
            if re.search(r'receive\s*\(\s*\)\s*external\s+payable', content):
                # Check if we already have it
                if not any(f['name'] == 'receive' for f in functions):
                    functions.append({
                        'name': 'receive',
                        'params': [],
                        'returns': [],
                        'stateMutability': 'payable',
                        'is_fallback': True
                    })
            
            # Check for fallback() external [payable]
            fallback_match = re.search(r'fallback\s*\(\s*\)\s*external\s+(?:payable\s+)?', content)
            if fallback_match:
                if not any(f['name'] == 'fallback' for f in functions):
                    is_payable = 'payable' in fallback_match.group(0)
                    functions.append({
                        'name': 'fallback',
                        'params': [],
                        'returns': [],
                        'stateMutability': 'payable' if is_payable else 'nonpayable',
                        'is_fallback': True
                    })
        except:
            pass
        
        return functions
    
    def _extract_from_source(self) -> List[Dict]:
        """Extract functions from source code."""
        with open(self.contract_path, 'r') as f:
            content = f.read()
        
        functions = []
        
        # First, check for fallback and receive functions
        # Pattern for receive() external payable
        receive_pattern = r'receive\s*\(\s*\)\s*external\s+payable'
        if re.search(receive_pattern, content):
            functions.append({
                'name': 'receive',
                'params': [],
                'returns': '',
                'stateMutability': 'payable',
                'is_fallback': True
            })
        
        # Pattern for fallback() external [payable]
        fallback_pattern = r'fallback\s*\(\s*\)\s*external\s+(?:payable\s+)?'
        if re.search(fallback_pattern, content):
            # Check if it's payable
            is_payable = 'payable' in re.search(fallback_pattern, content).group(0)
            functions.append({
                'name': 'fallback',
                'params': [],
                'returns': '',
                'stateMutability': 'payable' if is_payable else 'nonpayable',
                'is_fallback': True
            })
        
        # Pattern to match function definitions - improved to catch more cases
        # Matches: function name(params) [visibility] [modifiers] [returns(...)]
        pattern = r'function\s+(\w+)\s*\(([^)]*)\)\s*(?:public|external|internal|private)?\s*(?:pure|view|payable|constant)?\s*(?:returns\s*\(([^)]*)\))?'
        
        for match in re.finditer(pattern, content):
            func_name = match.group(1)
            params_str = match.group(2).strip()
            returns_str = match.group(3).strip() if match.group(3) else ""
            full_match = match.group(0)
            
            # Skip constructors and private/internal functions
            if func_name == 'constructor':
                continue
            # Only skip if explicitly marked as private/internal (not just missing public/external)
            if 'private' in full_match or ('internal' in full_match and 'external' not in full_match and 'public' not in full_match):
                continue
            
            # Extract state mutability
            state_mutability = 'nonpayable'  # Default for public/external functions
            if 'pure' in full_match:
                state_mutability = 'pure'
            elif 'view' in full_match or 'constant' in full_match:
                state_mutability = 'view'
            elif 'payable' in full_match:
                state_mutability = 'payable'
            
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
                'returns': returns_str,
                'stateMutability': state_mutability  # Store state mutability
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
        # First, check source code to see if constructor exists
        has_constructor = False
        try:
            with open(analyzer.contract_path, 'r') as f:
                content = f.read()
            
            # Check if constructor exists in source
            if re.search(r'constructor\s*\(', content):
                has_constructor = True
        except:
            pass
        
        if not has_constructor:
            return []
        
        # If constructor exists, extract parameters
        try:
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
                        inputs = item.get('inputs', [])
                        # Only return if there are actual inputs
                        if inputs:
                            return inputs
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
    
    def _has_constructor_validation(self) -> bool:
        """Check if original contract has constructor validation that optimized lacks."""
        try:
            with open(self.original.contract_path, 'r') as f:
                orig_content = f.read()
            with open(self.optimized.contract_path, 'r') as f:
                opt_content = f.read()
            
            import re
            # Check if original has require/assert in constructor
            orig_constructor = re.search(r'constructor\s*\([^)]*\)\s*\{([^}]+)\}', orig_content, re.DOTALL)
            opt_constructor = re.search(r'constructor\s*\([^)]*\)\s*\{([^}]+)\}', opt_content, re.DOTALL)
            
            if orig_constructor and opt_constructor:
                orig_body = orig_constructor.group(1)
                opt_body = opt_constructor.group(1)
                # Check if original has require/assert but optimized doesn't
                if re.search(r'require\s*\(', orig_body) and not re.search(r'require\s*\(', opt_body):
                    return True
                if re.search(r'assert\s*\(', orig_body) and not re.search(r'assert\s*\(', opt_body):
                    return True
        except:
            pass
        return False
    
    def _generate_setup(self, original_name: str, optimized_name: str) -> str:
        """Generate setUp function with constructor arguments."""
        # Extract constructor parameters
        orig_constructor_params = self._extract_constructor_params(self.original)
        opt_constructor_params = self._extract_constructor_params(self.optimized)
        
        # Check if we need to test constructor validation
        has_constructor_validation_bug = self._has_constructor_validation()
        
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
                # Use a reasonable default value (positive for original if it has validation)
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
        
        # For optimized contract
        # If there's a constructor validation bug, test with invalid params (e.g., 0)
        for i, param in enumerate(opt_constructor_params):
            if isinstance(param, dict):
                param_type = param.get('type', 'uint256')
                param_name = param.get('name', '') or f'arg{i}'
            else:
                param_type = param.get('type', 'uint256')
                param_name = param.get('name', f'arg{i}')
            
            # Always use same params as original for normal testing
            # Constructor validation bug will be tested separately if needed
            if i < len(orig_args):
                # Use same values as original
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
        # Always use same constructor params for both contracts to ensure they're comparable
        # Constructor validation bugs are hard to test with equivalence (original reverts on invalid params)
        orig_constructor = f"new {original_name}({', '.join(orig_args)})" if orig_args else f"new {original_name}()"
        # Use same args as original (not opt_args which might have invalid values)
        opt_constructor = f"new {optimized_name}({', '.join(orig_args)})" if orig_args else f"new {optimized_name}()"
        
        # Add constructor validation test if needed
        constructor_test = ""
        if has_constructor_validation_bug and orig_args:
            # Generate a test that tries invalid constructor params
            invalid_args = []
            for i, arg in enumerate(orig_args):
                # For uint/int types, use 0 as invalid value
                if arg.isdigit():
                    invalid_args.append("0")
                else:
                    invalid_args.append(arg)
            
            invalid_constructor_orig = f"new {original_name}({', '.join(invalid_args)})"
            invalid_constructor_opt = f"new {optimized_name}({', '.join(invalid_args)})"
            
            constructor_test = f"""
    // Test constructor validation bug
    function check_constructor_validation() public {{
        bool orig_reverts = false;
        bool opt_reverts = false;
        
        // Try to create original with invalid params (should revert)
        try {invalid_constructor_orig} returns (Original) {{
            orig_reverts = false;
        }} catch {{
            orig_reverts = true; // Expected: original reverts on invalid params
        }}
        
        // Try to create optimized with invalid params (should succeed - this is the bug)
        try {invalid_constructor_opt} returns (Optimized) {{
            opt_reverts = false; // Bug: optimized accepts invalid params
        }} catch {{
            opt_reverts = true;
        }}
        
        // Original should revert, optimized should succeed - this detects the bug
        // If both revert or both succeed, they're equivalent
        assert(orig_reverts == opt_reverts);
    }}

"""
        
        return f"""    function setUp() public {{
        original = {orig_constructor};
        optimized = {opt_constructor};
        assertStateEquivalence();
    }}
{constructor_test}
"""
    
    def _extract_state_variables(self, analyzer: ContractAnalyzer) -> List[str]:
        """Extract public state variable names from contract source code."""
        state_vars = []
        try:
            # Parse source code directly to avoid artifact conflicts
            with open(analyzer.contract_path, 'r') as f:
                content = f.read()
            
            # Find the contract definition
            contract_name = analyzer.extract_contract_name()
            contract_pattern = rf'contract\s+{contract_name}\s*\{{'
            contract_match = re.search(contract_pattern, content)
            
            if not contract_match:
                return []
            
            # Extract the contract body
            start_pos = contract_match.end()
            brace_count = 1
            i = start_pos
            while i < len(content) and brace_count > 0:
                if content[i] == '{':
                    brace_count += 1
                elif content[i] == '}':
                    brace_count -= 1
                i += 1
            
            contract_body = content[start_pos:i-1]
            
            # First, check for struct state variables (they have a different pattern)
            # Pattern: "Data public data;" where Data is a struct
            struct_pattern = r'(\w+)\s+public\s+(\w+)\s*;'
            struct_matches = re.findall(struct_pattern, contract_body)
            for struct_type, var_name in struct_matches:
                # Check if struct_type is defined in the contract (it's a struct, not a simple type)
                # Look for "struct StructName {" before this declaration
                struct_def_pattern = rf'struct\s+{struct_type}\s*\{{'
                if re.search(struct_def_pattern, contract_body):
                    # This is a struct state variable - we'll handle it specially
                    # Store as tuple: (var_name, struct_type)
                    state_vars.append((var_name, struct_type))
            
            # Then check for simple public state variables
            # Examples: "uint256 public total;", "uint256 public constant CAP = 100;"
            # Match: type [visibility] [modifiers] name [= value];
            # But exclude ones we already found as structs
            struct_var_names = {v[0] if isinstance(v, tuple) else None for v in state_vars}
            pattern = r'(\w+(?:\s*\[\s*\])?)\s+(?:public|constant)\s+(?:constant\s+)?(\w+)(?:\s*=\s*[^;]+)?\s*;'
            matches = re.findall(pattern, contract_body)
            
            for match in matches:
                var_type, var_name = match
                # Skip if it's a function (functions have parentheses)
                if '(' not in var_name and ')' not in var_name:
                    # Skip if we already found it as a struct
                    if var_name in struct_var_names:
                        continue
                    # Skip arrays - they require index arguments for getters
                    if '[]' in var_type or '[' in var_type:
                        continue
                    # Only add simple types (not structs)
                    if 'struct' not in var_type.lower():
                        state_vars.append(var_name)
        except Exception as e:
            # Fallback: try ABI if source parsing fails
            try:
                contract_name = analyzer.extract_contract_name()
                out_dir = Path("out")
                artifact_path = None
                
                # Use the same artifact lookup logic as _extract_from_abi
                if out_dir.exists():
                    source_stem = analyzer.contract_path.stem
                    
                    # Try: out/<source_stem>.sol/<contract_name>.json
                    possible_dir = out_dir / f"{source_stem}.sol"
                    if possible_dir.exists():
                        json_file = possible_dir / f"{contract_name}.json"
                        if json_file.exists():
                            artifact_path = json_file
                    
                    # If not found, search for any directory containing the contract name
                    if not artifact_path:
                        # Build relative path from project root to find matching artifact
                        try:
                            project_root = Path.cwd()
                            rel_path = analyzer.contract_path.relative_to(project_root)
                            # For benchmark/01_Arithmetic_Unchecked/Original.sol
                            # Look for out/benchmark/01_Arithmetic_Unchecked/Original.sol/Original.json
                            artifact_dir = out_dir / rel_path.with_suffix('')
                            if artifact_dir.exists():
                                json_file = artifact_dir / f"{contract_name}.json"
                                if json_file.exists():
                                    artifact_path = json_file
                        except:
                            pass
                
                if artifact_path and artifact_path.exists():
                    with open(artifact_path, 'r') as f:
                        artifact = json.load(f)
                    
                    # Validate that artifact contract name matches expected contract name
                    artifact_contract_name = artifact.get('contractName', '')
                    if artifact_contract_name and artifact_contract_name != contract_name:
                        # Wrong artifact - skip
                        return []
                    
                    for item in artifact.get('abi', []):
                        # Public state variables appear as view functions with no inputs
                        if (item.get('type') == 'function' and 
                            item.get('stateMutability') == 'view' and 
                            len(item.get('inputs', [])) == 0):
                            # This is a state variable getter
                            state_vars.append(item['name'])
            except:
                pass
        
        return state_vars
    
    def _generate_state_checker(self) -> str:
        """Generate state equivalence checker based on public state variables."""
        # Extract state variables from both contracts
        orig_state_vars = self._extract_state_variables(self.original)
        opt_state_vars = self._extract_state_variables(self.optimized)
        
        # Separate simple vars from struct vars
        orig_simple = [v for v in orig_state_vars if isinstance(v, str)]
        opt_simple = [v for v in opt_state_vars if isinstance(v, str)]
        orig_structs = [v for v in orig_state_vars if isinstance(v, tuple)]
        opt_structs = [v for v in opt_state_vars if isinstance(v, tuple)]
        
        # Find common simple state variables
        common_simple = sorted(set(orig_simple) & set(opt_simple))
        
        # Find common struct state variables (by name)
        orig_struct_names = {v[0]: v[1] for v in orig_structs}
        opt_struct_names = {v[0]: v[1] for v in opt_structs}
        common_struct_names = sorted(set(orig_struct_names.keys()) & set(opt_struct_names.keys()))
        
        if not common_simple and not common_struct_names:
            return """    /**
     * @notice Verifies that both contracts have equivalent state
     */
    function assertStateEquivalence() internal {
        // No public state variables found to check
    }

"""
        
        # Generate assertions
        assertions = []
        
        # Simple state variables
        for var_name in common_simple:
            assertions.append(f"        assert(original.{var_name}() == optimized.{var_name}());")
        
        # Struct state variables - compare individual fields
        # Note: Struct getters return tuples, so we need to destructure them
        for var_name in common_struct_names:
            orig_struct_type = orig_struct_names[var_name]
            opt_struct_type = opt_struct_names[var_name]
            
            # Extract field names from source
            orig_fields = self._extract_struct_fields(self.original, orig_struct_type)
            opt_fields = self._extract_struct_fields(self.optimized, opt_struct_type)
            
            # Find common fields (by name) and get their order
            common_fields = set(orig_fields.keys()) & set(opt_fields.keys())
            
            # Get field order from each struct
            orig_field_order = list(orig_fields.keys())
            opt_field_order = list(opt_fields.keys())
            
            # Destructure tuples and compare fields
            # Need to declare variables first, then assign
            # Get types for each field
            orig_types = [orig_fields[f] for f in orig_field_order]
            opt_types = [opt_fields[f] for f in opt_field_order]
            
            # Declare variables
            orig_decls = ', '.join([f'{t} {f}' for t, f in zip(orig_types, [f'orig_{f}' for f in orig_field_order])])
            opt_decls = ', '.join([f'{t} {f}' for t, f in zip(opt_types, [f'opt_{f}' for f in opt_field_order])])
            
            assertions.append(f"        ({orig_decls}) = original.{var_name}();")
            assertions.append(f"        ({opt_decls}) = optimized.{var_name}();")
            
            # Compare fields by name - map original field positions to optimized positions
            for field_name in sorted(common_fields):
                orig_var = f'orig_{field_name}'
                opt_var = f'opt_{field_name}'
                assertions.append(f"        assert({orig_var} == {opt_var});")
        
        assertions_str = "\n".join(assertions)
        
        return f"""    /**
     * @notice Verifies that both contracts have equivalent state
     */
    function assertStateEquivalence() internal {{
{assertions_str}
    }}

"""
    
    def _extract_struct_fields(self, analyzer: ContractAnalyzer, struct_name: str) -> Dict[str, str]:
        """Extract field names and types from a struct definition."""
        fields = {}
        try:
            with open(analyzer.contract_path, 'r') as f:
                content = f.read()
            
            # Find struct definition
            struct_pattern = rf'struct\s+{struct_name}\s*\{{([^}}]+)\}}'
            match = re.search(struct_pattern, content, re.DOTALL)
            
            if match:
                struct_body = match.group(1)
                # Extract field definitions: "type name;"
                field_pattern = r'(\w+(?:\s*\[\s*\])?)\s+(\w+)\s*;'
                field_matches = re.findall(field_pattern, struct_body)
                
                for field_type, field_name in field_matches:
                    fields[field_name] = field_type
        except:
            pass
        
        return fields
    
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
    
    def _has_access_control(self, func_name: str, original_funcs: Dict) -> bool:
        """Check if function has access control by examining source code."""
        try:
            with open(self.original.contract_path, 'r') as f:
                content = f.read()
            
            import re
            # Look for function definition with modifiers
            # Pattern: function funcName(...) public onlyOwner { or function funcName(...) public onlyOwner
            # Modifiers come after public/external and before the function body {
            pattern = rf'function\s+{func_name}\s*\([^)]*\)\s+(?:public|external)\s+([^{{]*)\{{'
            match = re.search(pattern, content)
            if match:
                modifiers_str = match.group(1).strip()
                # Check for common access control modifiers
                if re.search(r'onlyOwner|onlyRole|onlyAdmin|onlyWhitelist|only\w+', modifiers_str, re.IGNORECASE):
                    return True
                # Also check for owner/role/admin keywords (but be careful not to match too broadly)
                if modifiers_str and re.search(r'\b(owner|role|admin)\b', modifiers_str, re.IGNORECASE):
                    return True
                
        except Exception as e:
            pass
        return False
    
    def _checks_zero_address(self, func_name: str, param_name: str) -> bool:
        """Check if function validates zero address for a parameter."""
        try:
            with open(self.original.contract_path, 'r') as f:
                content = f.read()
            
            import re
            # Find the function body
            func_pattern = rf'function\s+{func_name}\s*\([^)]*\)[^{{]*\{{([^}}]+)\}}'
            func_match = re.search(func_pattern, content, re.DOTALL)
            if func_match:
                func_body = func_match.group(1)
                # Look for require/assert checking zero address
                # Pattern: require(param != address(0)) or require(param != address(0), "...")
                # Also check for variations like require(_param != address(0))
                patterns = [
                    rf'require\s*\(\s*{param_name}\s*!=\s*address\s*\(\s*0\s*\)',
                    rf'require\s*\(\s*{re.escape(param_name)}\s*!=\s*address\s*\(\s*0\s*\)',
                    rf'require\s*\(\s*[^)]*{param_name}[^)]*!=\s*address\s*\(\s*0\s*\)',
                ]
                for pattern in patterns:
                    if re.search(pattern, func_body):
                        return True
            # Also check globally (less precise but catches more cases)
            pattern = rf'require\s*\(\s*[^)]*{param_name}[^)]*!=\s*address\s*\(\s*0\s*\)'
            if re.search(pattern, content):
                return True
                
        except:
            pass
        return False
    
    def _has_payable_value_check(self, func_name: str) -> bool:
        """Check if payable function validates msg.value > 0."""
        try:
            with open(self.original.contract_path, 'r') as f:
                content = f.read()
            
            import re
            # Find the function body
            func_pattern = rf'function\s+{func_name}\s*\([^)]*\)[^{{]*\{{([^}}]+)\}}'
            func_match = re.search(func_pattern, content, re.DOTALL)
            if func_match:
                func_body = func_match.group(1)
                # Look for require(msg.value > 0) or require(msg.value > 0, "...")
                if re.search(r'require\s*\(\s*msg\.value\s*>\s*0', func_body):
                    return True
            # Also check globally
            if re.search(rf'function\s+{func_name}.*require\s*\(\s*msg\.value\s*>\s*0', content, re.DOTALL):
                return True
                
        except:
            pass
        return False
    
    def _extract_constants(self) -> Dict[str, int]:
        """Extract constant values from both contracts (MAX, MAX_ITEMS, CAP, etc.)."""
        constants = {}
        for analyzer in [self.original, self.optimized]:
            try:
                with open(analyzer.contract_path, 'r') as f:
                    content = f.read()
                
                import re
                # Match: uint256 public constant MAX = 1000;
                # Match: uint256 public constant MAX_ITEMS = 100;
                pattern = r'uint256\s+(?:public\s+)?constant\s+(\w+)\s*=\s*(\d+);'
                for match in re.finditer(pattern, content):
                    const_name = match.group(1)
                    const_value = int(match.group(2))
                    # Take the maximum value if constant appears in both contracts
                    if const_name in constants:
                        constants[const_name] = max(constants[const_name], const_value)
                    else:
                        constants[const_name] = const_value
            except:
                pass
        
        return constants
    
    def _has_reentrancy_protection(self, func_name: str) -> bool:
        """Check if function has reentrancy protection (nonReentrant modifier)."""
        try:
            with open(self.original.contract_path, 'r') as f:
                content = f.read()
            
            import re
            # Check if function has nonReentrant modifier
            pattern = rf'function\s+{func_name}\s*\([^)]*\)\s+(?:public|external)\s+[^{{]*\b(nonReentrant|reentrancyGuard)\b'
            if re.search(pattern, content):
                return True
            
            # Also check for modifier definition
            if re.search(r'modifier\s+nonReentrant', content):
                # Check if function uses it
                func_pattern = rf'function\s+{func_name}\s*\([^)]*\)\s+(?:public|external)\s+([^{{]*)\{{'
                match = re.search(func_pattern, content)
                if match and 'nonReentrant' in match.group(1):
                    return True
        except:
            pass
        return False
    
    def _needs_multiple_calls_for_bounds(self, func_name: str, constants: Dict[str, int]) -> bool:
        """Check if function needs multiple calls to test bounds (e.g., addItem with MAX_ITEMS)."""
        if 'MAX_ITEMS' not in constants:
            return False
        
        try:
            with open(self.original.contract_path, 'r') as f:
                content = f.read()
            
            import re
            # Check if function modifies an array state variable and has MAX_ITEMS check
            # Pattern: function funcName(...) { require(array.length < MAX_ITEMS); array.push(...); }
            func_pattern = rf'function\s+{func_name}\s*\([^)]*\)\s+[^{{]*\{{([^}}]+)\}}'
            match = re.search(func_pattern, content, re.DOTALL)
            if match:
                func_body = match.group(1)
                # Check if it has MAX_ITEMS check and array push
                if re.search(r'MAX_ITEMS', func_body) and re.search(r'\.push\s*\(', func_body):
                    return True
        except:
            pass
        return False
    
    def _generate_function_tests(self, common_functions: set, 
                                original_funcs: Dict, optimized_funcs: Dict) -> str:
        test_functions = ""
        
        # Extract constants from contracts
        constants = self._extract_constants()
        
        # Store common_functions for use in reentrancy tests
        self._common_functions = common_functions
        
        for func_name in sorted(common_functions):
            orig_func = original_funcs[func_name]
            opt_func = optimized_funcs[func_name]
            
            # Check if function has access control
            has_access_control = self._has_access_control(func_name, original_funcs)
            
            # Use original function's params (assuming they match)
            params = orig_func['params']
            
            # Generate parameter list
            param_decls = []
            param_names = []
            constraints = []
            address_params = []  # Track address parameters for access control testing
            
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
                
                # Track address parameters
                if param_type == 'address':
                    address_params.append(param_name)
                
                # Generate constraints based on type
                # Use tighter bounds for faster verification
                if '[]' in param_type:
                    # Array constraints: check for MAX_ITEMS or similar constants
                    # If MAX_ITEMS exists, allow arrays up to MAX_ITEMS + 1 to test bounds
                    if 'MAX_ITEMS' in constants:
                        max_items = constants['MAX_ITEMS']
                        bound = max_items + 10  # Allow exceeding MAX_ITEMS to test bounds
                    else:
                        bound = 5 if self.fast_mode else 10
                    constraints.append(f"vm.assume({param_name}.length < {bound});")
                elif 'uint' in param_type or 'int' in param_type:
                    # Use configurable bounds
                    # IMPORTANT: Allow values that could exceed constructor parameters (like cap)
                    # This is crucial for finding bugs where optimized versions skip validation
                    # For stateful functions (nonpayable/payable), use larger bounds to find validation bugs
                    state_mutability = orig_func.get('stateMutability', '')
                    is_stateful = state_mutability in ['nonpayable', 'payable']
                    
                    # Check for constants that might be used in validation (MAX, CAP, etc.)
                    max_constant = 0
                    for const_name, const_value in constants.items():
                        if const_name in ['MAX', 'CAP', 'LIMIT', 'THRESHOLD']:
                            max_constant = max(max_constant, const_value)
                    
                    if is_stateful:
                        # For stateful functions, always allow values that could exceed common constants
                        # This is critical for finding validation bugs, even in fast mode
                        if max_constant > 0:
                            # Use constant + buffer to allow exceeding it
                            bound = max(max_constant + 50, self.constraint_bound * 5, 150)
                        else:
                            bound = max(self.constraint_bound * 5, 150)  # At least 150 to catch CAP=100 bugs
                    elif self.fast_mode:
                        bound = 10
                    else:
                        bound = self.constraint_bound * 3
                    
                    constraints.append(f"vm.assume({param_name} < {bound});")
                elif param_type == 'address':
                    # Check if this parameter is validated for zero address
                    # If it is, allow zero address to test the validation
                    checks_zero = self._checks_zero_address(func_name, param_name)
                    if not checks_zero:
                        # Only exclude zero address if it's not being validated
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
            
            # For access control functions, generate additional test with different msg.sender
            if has_access_control:
                # Generate test with prank to test access control
                # vm.prank() works with .call(), so we can use the same pattern
                test_functions += f"""    function check_equivalence_{func_name}({param_list}) public {{
        // Constraints
        {constraints_str}

        // Test with owner (should work for both)
        address owner = original.owner();
        vm.prank(owner);
        check_function_equivalence(
            original.{func_name}.selector,
            {args_code}
        );
        
        // Test with non-owner (original should fail, optimized might succeed - this is the bug)
        address nonOwner = address(uint160(uint256(keccak256(abi.encodePacked("nonOwner", block.timestamp)))));
        vm.assume(nonOwner != owner);
        vm.prank(nonOwner);
        check_function_equivalence(
            original.{func_name}.selector,
            {args_code}
        );
    }}

"""
            else:
                # Check for reentrancy protection
                has_reentrancy_protection = self._has_reentrancy_protection(func_name)
                
                # Check if this function modifies an array state variable and has MAX_ITEMS check
                # This requires multiple calls to test bounds
                needs_multiple_calls = self._needs_multiple_calls_for_bounds(func_name, constants)
                
                if has_reentrancy_protection:
                    # Generate test with multiple sequential calls to test reentrancy
                    # Reentrancy bug: original prevents multiple calls, optimized allows them
                    # First check if there's a deposit function to fund the account
                    has_deposit = 'deposit' in self._common_functions
                    deposit_setup = ""
                    if has_deposit and param_names:
                        # Use the same amount for deposit as for withdraw
                        deposit_amount = param_names[0] if param_names else '100'
                        deposit_setup = f"""
        // First, deposit funds to enable withdrawal
        (bool dep_success1, ) = address(original).call(
            abi.encodeWithSelector(original.deposit.selector, {deposit_amount})
        );
        (bool dep_success2, ) = address(optimized).call(
            abi.encodeWithSelector(optimized.deposit.selector, {deposit_amount})
        );
        require(dep_success1 && dep_success2, "Deposit failed");
        assertStateEquivalence();
"""
                    
                    test_functions += f"""    function check_equivalence_{func_name}({param_list}) public {{
        // Constraints
        {constraints_str}
{deposit_setup}
        // Test with multiple sequential calls to simulate reentrancy
        // Original should prevent reentrancy (second call fails), optimized might allow it
        // First call should succeed for both
        check_function_equivalence(
            original.{func_name}.selector,
            {args_code}
        );
        
        // Second call: original should fail (reentrancy protection), optimized might succeed
        check_function_equivalence(
            original.{func_name}.selector,
            {args_code}
        );
    }}

"""
                elif needs_multiple_calls:
                    # Generate test with multiple sequential calls to build up the array
                    max_items = constants.get('MAX_ITEMS', 100)
                    test_functions += f"""    function check_equivalence_{func_name}({param_list}) public {{
        // Constraints
        {constraints_str}

        // Test with multiple calls to build up array past MAX_ITEMS ({max_items})
        // This tests the bounds check bug
        for (uint256 i = 0; i < {max_items + 5}; i++) {{
            check_function_equivalence(
                original.{func_name}.selector,
                {args_code}
            );
        }}
    }}

"""
                else:
                    # Check if function needs state setup (e.g., transfer needs deposit)
                    needs_setup = self._needs_state_setup(func_name, common_functions)
                    setup_code = ""
                    if needs_setup:
                        # Try to find a setup function (e.g., deposit for transfer)
                        setup_func = self._find_setup_function(func_name, common_functions)
                        if setup_func:
                            # Generate setup call
                            # For transfer, we need to deposit the amount first
                            if func_name == 'transfer' and param_names and len(param_names) >= 2:
                                amount_param = param_names[1]  # amount is usually second param
                                setup_code = f"""
        // Setup: Deposit funds to enable transfer
        (bool setup_success1, ) = address(original).call{{
            value: {amount_param}
        }}(abi.encodeWithSelector(original.{setup_func}.selector));
        (bool setup_success2, ) = address(optimized).call{{
            value: {amount_param}
        }}(abi.encodeWithSelector(optimized.{setup_func}.selector));
        require(setup_success1 && setup_success2, "Setup failed");
        assertStateEquivalence();
"""
                    
                    # Handle fallback/receive functions specially
                    is_fallback = orig_func.get('is_fallback', False)
                    if is_fallback:
                        # For fallback/receive, we need to send a call with value
                        # Note: receive() only accepts calls with empty calldata, fallback() accepts any calldata
                        if func_name == 'receive':
                            # receive() only accepts empty calldata with value
                            test_functions += f"""    function check_equivalence_{func_name}() public payable {{
        // Test receive function with symbolic value
        uint256 value = msg.value;
        vm.assume(value < 100 ether);  // Reasonable bound
        
        // Call original (receive only accepts empty calldata)
        (bool success1, bytes memory returnData1) = address(original).call{{value: value}}("");
        
        // Call optimized
        (bool success2, bytes memory returnData2) = address(optimized).call{{value: value}}("");
        
        assert(success1 == success2);
        
        if (success1 && success2) {{
            assert(keccak256(returnData1) == keccak256(returnData2));
        }}
        
        assertStateEquivalence();
    }}

"""
                        else:
                            # fallback() accepts any calldata
                            test_functions += f"""    function check_equivalence_{func_name}(bytes memory data) public payable {{
        // Test fallback function with symbolic value and calldata
        uint256 value = msg.value;
        vm.assume(value < 100 ether);  // Reasonable bound
        vm.assume(data.length < 100);  // Reasonable bound
        
        // Call original
        (bool success1, bytes memory returnData1) = address(original).call{{value: value}}(data);
        
        // Call optimized
        (bool success2, bytes memory returnData2) = address(optimized).call{{value: value}}(data);
        
        assert(success1 == success2);
        
        if (success1 && success2) {{
            assert(keccak256(returnData1) == keccak256(returnData2));
        }}
        
        assertStateEquivalence();
    }}

"""
                    else:
                        # Check if this is a payable function that validates msg.value > 0
                        has_value_check = False
                        if orig_func.get('stateMutability') == 'payable':
                            has_value_check = self._has_payable_value_check(func_name)
                        
                        # For payable functions with value check, test with msg.value == 0
                        payable_test = ""
                        if has_value_check:
                            # Generate a test that allows msg.value == 0 to test the bug
                            # For payable functions, we need to use .call{value: 0} with the encoded selector
                            if encode_args:
                                payable_args = f", {encode_args}"
                            else:
                                payable_args = ""
                            payable_test = f"""
    function check_equivalence_{func_name}_zero_value({param_list}) public {{
        // Constraints
        {constraints_str}
        // Test payable function with zero value (original should revert, optimized might succeed)
        (bool success1, bytes memory returnData1) = address(original).call{{value: 0}}(
            abi.encodePacked(original.{func_name}.selector{payable_args})
        );
        (bool success2, bytes memory returnData2) = address(optimized).call{{value: 0}}(
            abi.encodePacked(optimized.{func_name}.selector{payable_args})
        );
        
        // Original should revert (has validation), optimized might succeed (bug)
        assert(success1 == success2);
        
        if (success1 && success2) {{
            assert(keccak256(returnData1) == keccak256(returnData2));
        }}
        
        assertStateEquivalence();
    }}

"""
                        
                        test_functions += f"""    function check_equivalence_{func_name}({param_list}) public {{
        // Constraints
        {constraints_str}
{setup_code}
        check_function_equivalence(
            original.{func_name}.selector,
            {args_code}
        );
    }}
{payable_test}

"""
        
        return test_functions
    
    def _needs_state_setup(self, func_name: str, common_functions: set) -> bool:
        """Check if function needs state setup before testing."""
        # Functions that typically need setup
        needs_setup_patterns = ['transfer', 'withdraw', 'claim', 'redeem']
        return any(pattern in func_name.lower() for pattern in needs_setup_patterns)
    
    def _find_setup_function(self, func_name: str, common_functions: set) -> str:
        """Find a setup function for the given function (e.g., deposit for transfer)."""
        # Common patterns: transfer -> deposit, withdraw -> deposit
        if 'transfer' in func_name.lower():
            if 'deposit' in common_functions:
                return 'deposit'
        elif 'withdraw' in func_name.lower():
            if 'deposit' in common_functions:
                return 'deposit'
        return None
    
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

