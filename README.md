# hamlosOptim

LLM-based Solidity contract optimization with **Halmos** formal verification and **Slither** static analysis. The pipeline generates optimized contracts, checks them with Slither for security issues, then proves equivalence to the original using Halmos; on failure, counterexamples are fed back to the LLM for repair.

## Overview

- **Optimize**: An LLM produces an optimized version of a given Solidity contract.
- **Slither**: Static analysis catches High/Medium issues; the LLM is asked to fix them (up to a few iterations).
- **Halmos**: Symbolic equivalence testing between original and optimized contract; failing tests produce counterexamples.
- **Repair loop**: Counterexamples are sent back to the LLM; the cycle repeats until verification passes or a max iteration count is reached.

## Prerequisites

- **Foundry** (Forge) — build and test  
  https://book.getfoundry.sh/
- **Halmos** — symbolic testing (install and ensure `halmos` is on `PATH`)  
  https://github.com/a16z/halmos
- **Python 3** with:
  - `openai` — for LLM API (OpenAI or Ollama-compatible)
  - `python-dotenv` — for `.env` (e.g. API keys)
  - Optional: `slither-analyzer` — for Slither integration

For **local LLMs** (Ollama):

- Install [Ollama](https://ollama.ai) and pull a model, e.g. `ollama pull llama3`

## Quick start

### Build and test (Foundry)

```bash
forge build
forge test
```

### Verify two contracts (Original vs Optimized)

```bash
python3 auto_verify.py <original_contract> <optimized_contract>
# Example:
python3 auto_verify.py benchmark/06_Reentrancy_Protection/Original.sol benchmark/06_Reentrancy_Protection/Optimized.sol
```

### Run LLM optimization + verification (single contract)

Uses a local model (e.g. Ollama) by default:

```bash
python3 llm_optimize_verify.py <original_contract> [--max-iterations N] [--model MODEL]
# Example:
python3 llm_optimize_verify.py benchmark/06_Reentrancy_Protection/Original.sol --max-iterations 5
```

With **OpenAI** (set `OPENAI_API_KEY`):

```bash
python3 llm_optimize_verify.py benchmark/06_Reentrancy_Protection/Original.sol --model gpt-4
```

With a **custom base URL** (e.g. another Ollama instance):

```bash
python3 llm_optimize_verify.py path/to/Original.sol --base-url http://host:11434/v1
```

### Pipeline: optimize and write to `src/`

Runs the same flow as above and, on success, records results and copies the verified contract to `src/Opt_<name>.sol`:

```bash
python3 run_optimization_pipeline.py <original_contract> [--max-iterations N] [--model MODEL]
# Multiple LLM endpoints (fallback or round-robin):
python3 run_optimization_pipeline.py path/to/contract.sol --base-url http://host1:11434/v1 --base-url http://host2:11434/v1 [--round-robin]
```

### Agent experiment (benchmark suite)

Runs the iterative optimizer on all benchmark cases that have `Original.sol` and writes results to `agent_experiment_results.json`. Requires `OPENAI_API_KEY`:

```bash
python3 run_agent_experiment.py
```

### Benchmark verification (Original vs Optimized)

Runs the verification pipeline on all benchmark pairs in `benchmark/*/Original.sol` and `benchmark/*/Optimized.sol`:

```bash
python3 run_benchmark.py
```

## Project layout

| Path | Description |
|------|-------------|
| `llm_optimize_verify.py` | Main iterative optimizer: LLM → Slither → Halmos → repair loop |
| `auto_verify.py` | Verification pipeline: harness generation, Forge build, Halmos run |
| `run_optimization_pipeline.py` | Single-contract pipeline + write to `src/` + `optimization_record.json` |
| `run_agent_experiment.py` | Batch run over benchmark cases (OpenAI) |
| `run_benchmark.py` | Batch verification of benchmark Original/Optimized pairs |
| `benchmark/` | Benchmark cases: `NN_Name/Original.sol`, `NN_Name/Optimized.sol` |
| `test/AutoEquivalenceTest.t.sol` | Auto-generated equivalence test (updated by pipeline) |
| `llm_optimized/` | Output directory for LLM-produced optimized contracts |
| `Solo/` | Submodule: alternate optimizer (source-gen based) |

## Foundry reference

- **Build**: `forge build`
- **Test**: `forge test`
- **Format**: `forge fmt`
- **Gas snapshot**: `forge snapshot`
- **Local node**: `anvil`
- **Cast**: `cast <subcommand>`

Full docs: https://book.getfoundry.sh/
