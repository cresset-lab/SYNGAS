# Slither-Guided Repair Integration (Experiment III)

## Overview

This document describes the Slither-Guided Repair integration added to `llm_optimize_verify.py`. This implements **Experiment III** for the paper, which adds a Slither static analysis feedback loop before Halmos verification.

## Architecture

The optimization loop now follows this flow:

```
Step A: LLM generates candidate optimized code
    ↓
Step B: Slither Analysis Loop (up to 3 iterations)
    ├─ Run Slither on candidate code
    ├─ IF issues found:
    │   ├─ Construct feedback: "Your code has security vulnerabilities. Slither reported: [issues]"
    │   ├─ Call LLM to repair (iterate up to 3 times)
    │   └─ Loop back to Slither analysis
    └─ ELSE: Proceed to Step C
    ↓
Step C: Halmos Verification
    └─ Only runs after Slither is clean
```

## Key Functions

### `run_slither_analysis(source_code: str) -> List[str]`

Runs Slither static analysis on Solidity source code.

**Process:**
1. Creates a temporary file with the source code
2. Runs `slither <file> --json -`
3. Parses JSON output to extract High/Medium severity issues
4. Returns list of issue descriptions (e.g., `["Reentrancy in function withdraw"]`)

**Returns:**
- List of issue strings (empty if no issues or Slither not installed)

**Error Handling:**
- Gracefully handles Slither not being installed
- Handles JSON parsing errors
- Falls back to text parsing if JSON fails
- Cleans up temporary files

### Modified `LLMOptimizer.optimize_contract()`

Now accepts an optional `slither_feedback` parameter:

```python
def optimize_contract(self, contract_path: str, original_code: str, 
                     counterexamples: List[Dict] = None, iteration: int = 0,
                     slither_feedback: List[str] = None) -> str:
```

When `slither_feedback` is provided, the prompt prioritizes security fixes over optimization.

### Modified `IterativeOptimizer.run()`

The main loop now includes:

1. **Step A**: Generate optimized code (as before)
2. **Step B**: Slither Analysis Loop
   - Runs Slither on the generated code
   - If issues found, requests LLM to fix them (up to 3 iterations)
   - Only proceeds to Halmos if Slither is clean
3. **Step C**: Halmos Verification (unchanged)

## Example: Benchmark 06 (Reentrancy Protection)

**Scenario:**
- Original contract has `nonReentrant` modifier
- LLM optimizes by removing it (gas optimization)
- Slither detects: "Reentrancy in function withdraw"
- LLM fixes by adding back `nonReentrant` modifier
- Halmos verification passes

**Expected Flow:**
```
Iteration 1:
  Step A: LLM generates code without nonReentrant
  Step B.1: Slither detects reentrancy issue
  Step B.2: LLM fixes by adding nonReentrant back
  Step B.3: Slither passes (no issues)
  Step C: Halmos verification passes
```

## Installation

To use Slither integration, install Slither:

```bash
pip install slither-analyzer
```

Or use the Solidity development environment that includes it.

## Usage

The integration is automatic when running:

```bash
python3 llm_optimize_verify.py benchmark/06_Reentrancy_Protection/Original.sol
```

The script will:
1. Generate optimized code
2. Run Slither analysis
3. Fix any security issues detected
4. Run Halmos verification

## Testing

Test the Slither integration:

```bash
python3 test_slither_integration.py
```

This tests Slither on `benchmark/06_Reentrancy_Protection/Optimized.sol` to verify it detects reentrancy issues.

## Benefits

1. **Catches security bugs early**: Before expensive Halmos verification
2. **Guided repair**: Slither provides specific feedback on what's wrong
3. **Iterative improvement**: LLM can fix issues in multiple passes
4. **Complements Halmos**: Catches issues Halmos might miss (like reentrancy in single-call equivalence)

## Limitations

1. **Slither must be installed**: Falls back gracefully if not available
2. **False positives**: Slither may report issues that aren't actual bugs
3. **Limited to High/Medium**: Only High and Medium severity issues trigger repair
4. **Temp file handling**: Requires write permissions for temp directory

