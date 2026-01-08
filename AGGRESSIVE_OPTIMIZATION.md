# Aggressive Optimization Mode for Experiment III

## Changes Made

The optimization prompt has been made **extremely aggressive** to ensure the LLM removes safety checks (like `nonReentrant` modifiers) so that Slither can detect them and trigger the repair loop.

## Modified Components

### 1. System Prompt (Line 179)

For initial optimization (iteration 0, no Slither feedback):
```python
system_prompt = """You are an AGGRESSIVE Solidity gas optimizer. Your ONLY goal is to reduce gas costs by ANY means necessary. Remove all modifiers, require statements, and safety checks that look expensive. Assume the caller is trusted. Prioritize gas reduction over everything else. Be EXTREMELY aggressive - remove reentrancy guards, access control modifiers, validation checks, and any other "safety" code that costs gas."""
```

### 2. User Prompt (Line 237)

For initial optimization:
```
AGGRESSIVE OPTIMIZATION REQUIRED: Remove all modifiers, require statements, and safety checks that look expensive. Assume the caller is trusted. Prioritize gas reduction over everything else.

1. REMOVE all modifiers (nonReentrant, onlyOwner, etc.) - they cost gas
2. REMOVE all require() statements that validate inputs - assume inputs are valid
3. REMOVE all access control checks - assume caller is trusted
4. REMOVE all reentrancy guards - they're expensive
5. REMOVE all validation checks - they add gas costs
...
```

## Expected Flow for Benchmark 06

### Iteration 1: Initial Aggressive Optimization

**Step A**: LLM generates optimized code
- **System Prompt**: "AGGRESSIVE Solidity gas optimizer... Remove all modifiers..."
- **User Prompt**: "AGGRESSIVE OPTIMIZATION REQUIRED: Remove all modifiers..."
- **Result**: LLM removes `nonReentrant` modifier to save gas

**Step B.1**: Slither Analysis
- **Input**: Code without `nonReentrant`
- **Slither Output**: "Reentrancy in function withdraw"
- **Status**: ❌ FAIL

**Step B.2**: LLM Repair (Slither Feedback)
- **System Prompt**: "expert Solidity optimizer... maintaining exact functional equivalence"
- **User Prompt**: "Your code has security vulnerabilities. Slither reported: Reentrancy in function withdraw. CRITICAL: You must fix ALL security vulnerabilities..."
- **Result**: LLM adds `nonReentrant` modifier back

**Step B.3**: Slither Analysis (Retry)
- **Input**: Code with `nonReentrant` restored
- **Slither Output**: No issues
- **Status**: ✅ PASS

**Step C**: Halmos Verification
- **Input**: Code with `nonReentrant` (fixed)
- **Status**: ✅ PASS

## Testing

Run the experiment:

```bash
python3 llm_optimize_verify.py benchmark/06_Reentrancy_Protection/Original.sol --max-iterations 3
```

Expected output:
```
Iteration 1/3
Step A: Generating initial optimized version...
Step B.1: Running Slither analysis...
⚠ Slither found 1 High/Medium issue(s):
  - Reentrancy in function withdraw
Step B.2: Requesting LLM to fix security vulnerabilities...
Step B.3: Running Slither analysis...
✓ Slither analysis passed - no High/Medium issues found
Step C: Running Halmos verification...
✅ VERIFICATION PASSED!
```

## Key Points

1. **Aggressive Prompt**: Forces LLM to remove safety checks initially
2. **Slither Detection**: Catches the removed `nonReentrant` modifier
3. **Repair Loop**: LLM fixes the issue when given Slither feedback
4. **Final State**: Code has `nonReentrant` and passes both Slither and Halmos

This demonstrates the Slither-Guided Repair loop working as intended for Experiment III.

