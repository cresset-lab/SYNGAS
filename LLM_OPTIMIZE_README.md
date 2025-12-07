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
# Install OpenAI package
pip install openai

# Or use the virtual environment
source venv/bin/activate
pip install openai
```

## Setup

Set your OpenAI API key:

```bash
export OPENAI_API_KEY=your_api_key_here
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

# Different model
python3 llm_optimize_verify.py src/CappedDeposits.sol --model gpt-3.5-turbo

# Custom API key
python3 llm_optimize_verify.py src/CappedDeposits.sol --api-key sk-...
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

If no API key is set, the script runs in "mock mode" with a simple optimizer (for testing). This creates intentionally buggy optimizations to test the verification loop.

## Requirements

- **OpenAI API Key**: For LLM optimization
- **Halmos**: For verification (install via pip or venv)
- **Foundry**: For contract compilation

## Tips

1. **Start Small**: Test with simple contracts first
2. **Monitor Costs**: Each iteration uses API credits
3. **Review Output**: Check generated contracts before using
4. **Adjust Iterations**: More iterations = better chance of success but higher cost

## Troubleshooting

**"OPENAI_API_KEY not set"**
- Set the environment variable or use `--api-key` flag

**"Halmos not found"**
- Activate venv: `source venv/bin/activate`
- Or install: `pip install halmos`

**"Max iterations reached"**
- The LLM couldn't find a correct optimization
- Review the last generated contract manually
- Try increasing `--max-iterations`

## Advanced Usage

### Custom LLM Provider

Modify `LLMOptimizer` class to use a different LLM API (Anthropic, etc.)

### Custom Prompts

Edit `_build_optimization_prompt()` to customize optimization instructions

### Integration with CI/CD

```yaml
# .github/workflows/optimize.yml
- name: Optimize Contract
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
  run: python3 llm_optimize_verify.py src/MyContract.sol
```

