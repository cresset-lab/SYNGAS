# LLM-Based Iterative Contract Optimization

This script automatically optimizes Solidity contracts using an LLM and iteratively fixes bugs based on Halmos counterexamples.

## How It Works

```
Original Contract
      ↓
[LLM Optimization]
      ↓
Optimized Contract
      ↓
[Halmos Verification]
      ↓
   ┌─────┴─────┐
   │           │
PASS        FAIL
   │           │
   │      [Counterexample]
   │           │
   │      [LLM Fix]
   │           │
   └───────┬─────┘
           ↓
    (Iterate until PASS or max iterations)
```

## Installation

```bash
# Install OpenAI package (used for Ollama's OpenAI-compatible API)
pip install openai

# Or use the virtual environment
source venv/bin/activate
pip install openai

# Install and setup Ollama (local LLM server)
# Visit https://ollama.ai for installation instructions
# Then pull a model:
ollama pull llama3
```

## Setup

The script uses **local LLMs only** via Ollama by default. No API keys needed!

```bash
# Make sure Ollama is running (default: http://localhost:11434)
# Check with: curl http://localhost:11434/api/tags

# Optional: Set custom Ollama URL
export OLLAMA_BASE_URL=http://localhost:11434/v1
```

## Usage

### Basic Usage

```bash
python3 llm_optimize_verify.py src/CappedDeposits.sol
```

### With Custom Settings

```bash
# More iterations
python3 llm_optimize_verify.py src/CappedDeposits.sol --max-iterations 10

# Different local model (must be available in Ollama)
python3 llm_optimize_verify.py src/CappedDeposits.sol --model llama3.2

# Custom Ollama server URL
python3 llm_optimize_verify.py src/CappedDeposits.sol --base-url http://localhost:11434/v1

# List available models in Ollama
ollama list
```

## Workflow

1. **Initial Optimization**: LLM generates an optimized version
2. **Verification**: Halmos checks equivalence
3. **If Pass**: ✅ Done! Optimized contract is saved
4. **If Fail**: 
   - Counterexamples are extracted
   - LLM receives counterexamples and fixes the optimization
   - Process repeats

## Output

Optimized contracts are saved in `llm_optimized/`:
- `ContractOpt_iter1.sol` - First attempt
- `ContractOpt_iter2.sol` - Second attempt (if first failed)
- etc.

## Example Output

```
======================================================================
LLM-Based Iterative Contract Optimization
======================================================================
Original: src/CappedDeposits.sol
Max iterations: 5
======================================================================

======================================================================
Iteration 1/5
======================================================================
Generating initial optimized version...
[SUCCESS] Optimized contract saved: llm_optimized/CappedDepositsOpt_iter1.sol
Running equivalence verification...
[WARNING] Verification failed. Found 1 counterexample(s).

Counterexample 1:
  Function: check_equivalence_deposit
  Input: {'amount': '24'}
  Issue: Behavior differs from original contract

Attempting to fix issues and retry...

======================================================================
Iteration 2/5
======================================================================
Fixing optimization based on 1 counterexample(s)...
[SUCCESS] Optimized contract saved: llm_optimized/CappedDepositsOpt_iter2.sol
Running equivalence verification...
[SUCCESS] ✅ VERIFICATION PASSED!
======================================================================
✅ VERIFICATION PASSED!
======================================================================
Optimized contract is equivalent to original!
Final version: llm_optimized/CappedDepositsOpt_iter2.sol
```

## Mock Mode

If the `openai` package is not installed or Ollama is not running, the script runs in "mock mode" with a simple optimizer (for testing). This creates intentionally buggy optimizations to test the verification loop.

## Requirements

- **Ollama**: Local LLM server (https://ollama.ai)
- **Local LLM Model**: Pull a model first (e.g., `ollama pull llama3`)
- **Halmos**: For verification (install via pip or venv)
- **Foundry**: For contract compilation

## Tips

1. **Start Small**: Test with simple contracts first
2. **Choose Right Model**: Larger models (llama3) give better results but are slower
3. **Review Output**: Check generated contracts before using
4. **Adjust Iterations**: More iterations = better chance of success
5. **Ollama Performance**: Ensure Ollama has enough RAM/VRAM for your model

## Troubleshooting

**"Ollama connection failed" or "Connection refused"**
- Make sure Ollama is running: `ollama serve` (or it should auto-start)
- Check if Ollama is accessible: `curl http://localhost:11434/api/tags`
- Verify the model exists: `ollama list`

**"Model not found"**
- Pull the model first: `ollama pull llama3`
- Or use a different model: `--model llama3.2`

**"Halmos not found"**
- Activate venv: `source venv/bin/activate`
- Or install: `pip install halmos`

**"Max iterations reached"**
- The LLM couldn't find a correct optimization
- Review the last generated contract manually
- Try increasing `--max-iterations`
- Try a larger/better model

## Advanced Usage

### Custom LLM Provider

The script uses Ollama by default (local LLMs). To use a different provider:
- Modify `LLMOptimizer` class to use a different LLM API
- Or set `--base-url` to point to another OpenAI-compatible API server

### Custom Prompts

Edit `_build_optimization_prompt()` to customize optimization instructions

### Integration with CI/CD

```yaml
# .github/workflows/optimize.yml
- name: Setup Ollama
  run: |
    curl -fsSL https://ollama.ai/install.sh | sh
    ollama pull llama3

- name: Optimize Contract
  run: python3 llm_optimize_verify.py src/MyContract.sol
```

