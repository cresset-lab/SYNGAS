# Quick Start: LLM-Based Iterative Optimization

## Overview

This script automatically optimizes Solidity contracts using an LLM and iteratively fixes bugs based on Halmos counterexamples.

## Installation

```bash
# Install OpenAI package (used for Ollama's OpenAI-compatible API)
pip install openai

# Or in virtual environment
source venv/bin/activate
pip install openai

# Install Ollama (local LLM server)
# Visit https://ollama.ai for installation
# Then pull a model:
ollama pull llama3
```

## Setup

The script uses **local LLMs only** via Ollama. No API keys needed!

```bash
# Make sure Ollama is running (should auto-start)
# Verify: curl http://localhost:11434/api/tags
```

## Usage

```bash
# Basic usage (requires Ollama running)
python3 llm_optimize_verify.py src/CappedDeposits.sol

# With more iterations
python3 llm_optimize_verify.py src/CappedDeposits.sol --max-iterations 10

# With different model
python3 llm_optimize_verify.py src/CappedDeposits.sol --model llama3.2
```

## How It Works

1. **LLM Optimization**: Generates optimized version
2. **Halmos Verification**: Checks equivalence
3. **If Pass**: ✅ Done!
4. **If Fail**: 
   - Extracts counterexamples
   - Feeds to LLM for fixes
   - Repeats

## Output

- Optimized contracts: `llm_optimized/ContractOpt_iterN.sol`
- Verification logs: `proof_results/halmos_iterN_*.log`

## Example Flow

```
Iteration 1: Generate optimization
  → Halmos finds counterexample (amount=24 exceeds cap=20)
  → LLM receives: "Fix: amount 24 exceeds cap 20"
  
Iteration 2: LLM fixes the bug
  → Adds back cap check
  → Halmos verifies: ✅ PASS
```

## Mock Mode

Without Ollama running or if `openai` package is missing, uses simple mock optimizer (for testing).

## See Also

- `LLM_OPTIMIZE_README.md` - Full documentation
- `auto_verify.py` - Manual verification tool

