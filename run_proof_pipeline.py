#!/usr/bin/env python3
"""
Halmos Equivalence Proof Pipeline

This script automates the process of:
1. Building Solidity contracts
2. Generating test harnesses (optional)
3. Running Halmos symbolic verification
4. Parsing and reporting results
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple

# Color codes for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

def log_info(msg: str):
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")

def log_success(msg: str):
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {msg}")

def log_warning(msg: str):
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {msg}")

def log_error(msg: str):
    print(f"{Colors.RED}[ERROR]{Colors.NC} {msg}")

class ProofPipeline:
    def __init__(self, config: Dict):
        self.project_root = Path(config.get('project_root', os.getcwd()))
        self.test_file = config.get('test_file', 'test/GeneralizedEquivalenceTest.t.sol')
        self.generate_tests = config.get('generate_tests', False)
        self.halmos_args = config.get('halmos_args', [
            '--solver-timeout-assertion', '0',
            '--solver-timeout-unknown', '0'
        ])
        self.output_dir = Path(config.get('output_dir', 'proof_results'))
        self.output_dir.mkdir(exist_ok=True)
        
    def build_contracts(self) -> bool:
        """Build Solidity contracts using Foundry."""
        log_info("Building Solidity contracts...")
        
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
            log_error(f"Contract build failed: {e.stderr}")
            return False
        except FileNotFoundError:
            log_error("Foundry not found. Please install Foundry: https://getfoundry.sh/")
            return False
    
    def generate_test_harness(self) -> bool:
        """Generate test harness using Python script."""
        if not self.generate_tests:
            log_info("Skipping test generation (set generate_tests=true to enable)")
            return True
        
        log_info("Generating test harness...")
        generate_script = self.project_root / 'generate_proof.py'
        
        if not generate_script.exists():
            log_warning("generate_proof.py not found, skipping test generation")
            return False
        
        try:
            result = subprocess.run(
                [sys.executable, str(generate_script)],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                check=True
            )
            log_success("Test harness generated")
            return True
        except subprocess.CalledProcessError as e:
            log_warning(f"Test harness generation failed: {e.stderr}")
            return False
    
    def run_halmos(self) -> Tuple[bool, str]:
        """Run Halmos symbolic verification."""
        log_info(f"Running Halmos symbolic verification on {self.test_file}...")
        
        # Check if halmos is available
        try:
            subprocess.run(['halmos', '--version'], capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            log_error("Halmos not found. Please install it or activate your virtual environment.")
            log_info("Try: source venv/bin/activate")
            return False, ""
        
        # Prepare output file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = self.output_dir / f'halmos_{timestamp}.log'
        
        # Build command
        cmd = ['halmos'] + self.halmos_args + ['--contract', str(self.test_file)]
        log_info(f"Command: {' '.join(cmd)}")
        
        try:
            with open(output_file, 'w') as f:
                result = subprocess.run(
                    cmd,
                    cwd=self.project_root,
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    text=True,
                    check=False
                )
            
            # Read output for parsing
            with open(output_file, 'r') as f:
                output = f.read()
            
            if result.returncode == 0:
                log_success("Halmos verification completed")
            else:
                log_error(f"Halmos verification failed with exit code {result.returncode}")
            
            log_info(f"Results saved to: {output_file}")
            return result.returncode == 0, str(output_file)
            
        except Exception as e:
            log_error(f"Error running Halmos: {e}")
            return False, ""
    
    def parse_results(self, output_file: str) -> Dict:
        """Parse Halmos output and extract metrics."""
        log_info(f"Parsing results from {output_file}...")
        
        metrics = {
            'total_tests': 0,
            'passed': 0,
            'failed': 0,
            'counterexamples': 0,
            'errors': []
        }
        
        try:
            with open(output_file, 'r') as f:
                content = f.read()
            
            # Count test functions
            metrics['total_tests'] = content.count('check_equivalence_')
            
            # Count passes and failures
            metrics['passed'] = content.count('PASS') + content.count('✓')
            metrics['failed'] = content.count('FAIL') + content.count('✗')
            metrics['counterexamples'] = content.count('Counterexample')
            
            # Extract errors
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'Error' in line or 'error' in line.lower():
                    # Get context around error
                    context = '\n'.join(lines[max(0, i-2):min(len(lines), i+3)])
                    metrics['errors'].append(context)
            
        except Exception as e:
            log_warning(f"Error parsing results: {e}")
        
        return metrics
    
    def generate_summary(self, metrics: Dict, output_file: str) -> str:
        """Generate summary report."""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        summary_file = self.output_dir / f'summary_{timestamp}.txt'
        
        with open(summary_file, 'w') as f:
            f.write("=" * 50 + "\n")
            f.write("Halmos Equivalence Proof Summary\n")
            f.write("=" * 50 + "\n")
            f.write(f"Test File: {self.test_file}\n")
            f.write(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("-" * 50 + "\n")
            f.write(f"Total Tests: {metrics['total_tests']}\n")
            f.write(f"Passed: {metrics['passed']}\n")
            f.write(f"Failed: {metrics['failed']}\n")
            f.write(f"Counterexamples Found: {metrics['counterexamples']}\n")
            f.write("=" * 50 + "\n")
            
            if metrics['errors']:
                f.write("\nErrors:\n")
                f.write("-" * 50 + "\n")
                for error in metrics['errors'][:5]:  # Limit to first 5 errors
                    f.write(f"{error}\n\n")
        
        return str(summary_file)
    
    def run(self) -> bool:
        """Execute the full pipeline."""
        log_info("=" * 50)
        log_info("Halmos Equivalence Proof Pipeline")
        log_info("=" * 50)
        log_info(f"Project Root: {self.project_root}")
        log_info(f"Test File: {self.test_file}")
        log_info("=" * 50)
        
        # Step 1: Build contracts
        if not self.build_contracts():
            log_error("Pipeline failed at build step")
            return False
        
        # Step 2: Generate test harness (optional)
        if not self.generate_test_harness():
            log_warning("Test generation had issues, but continuing...")
        
        # Step 3: Run Halmos
        success, output_file = self.run_halmos()
        if not success and not output_file:
            log_error("Pipeline failed at Halmos verification step")
            return False
        
        # Step 4: Parse results
        if output_file:
            metrics = self.parse_results(output_file)
            summary_file = self.generate_summary(metrics, output_file)
            
            # Display summary
            with open(summary_file, 'r') as f:
                print(f.read())
            
            # Check for failures
            if metrics['failed'] > 0 or metrics['counterexamples'] > 0:
                log_warning("Some tests failed or counterexamples were found!")
                log_info(f"Review the full output: {output_file}")
                return False
            else:
                log_success("All equivalence proofs passed!")
        
        log_success("=" * 50)
        log_success("Pipeline completed successfully!")
        log_success("=" * 50)
        return True

def load_config(config_file: Optional[str] = None) -> Dict:
    """Load configuration from file or use defaults."""
    default_config = {
        'project_root': os.getcwd(),
        'test_file': 'test/GeneralizedEquivalenceTest.t.sol',
        'generate_tests': False,
        'halmos_args': [
            '--solver-timeout-assertion', '0',
            '--solver-timeout-unknown', '0'
        ],
        'output_dir': 'proof_results'
    }
    
    if config_file and os.path.exists(config_file):
        try:
            with open(config_file, 'r') as f:
                user_config = json.load(f)
            default_config.update(user_config)
        except Exception as e:
            log_warning(f"Error loading config file: {e}. Using defaults.")
    
    return default_config

def main():
    parser = argparse.ArgumentParser(
        description='Halmos Equivalence Proof Pipeline',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run with default settings
  python run_proof_pipeline.py

  # Run with specific test file
  python run_proof_pipeline.py --test test/AutoGeneratedTest.t.sol

  # Run with test generation enabled
  python run_proof_pipeline.py --generate-tests

  # Run with custom Halmos arguments
  python run_proof_pipeline.py --halmos-args "--solver-timeout-assertion 300"
        """
    )
    
    parser.add_argument(
        '--test',
        dest='test_file',
        default='test/GeneralizedEquivalenceTest.t.sol',
        help='Path to test file (default: test/GeneralizedEquivalenceTest.t.sol)'
    )
    
    parser.add_argument(
        '--generate-tests',
        action='store_true',
        help='Generate test harness before running Halmos'
    )
    
    parser.add_argument(
        '--config',
        help='Path to JSON configuration file'
    )
    
    parser.add_argument(
        '--halmos-args',
        nargs='+',
        help='Additional arguments to pass to Halmos'
    )
    
    parser.add_argument(
        '--output-dir',
        default='proof_results',
        help='Directory for output files (default: proof_results)'
    )
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    
    # Override with command-line arguments
    if args.test_file:
        config['test_file'] = args.test_file
    if args.generate_tests:
        config['generate_tests'] = True
    if args.halmos_args:
        config['halmos_args'] = args.halmos_args
    if args.output_dir:
        config['output_dir'] = args.output_dir
    
    # Run pipeline
    pipeline = ProofPipeline(config)
    success = pipeline.run()
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

