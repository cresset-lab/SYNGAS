# Benchmark Suite Guide

This benchmark suite contains 50 test cases covering various gas optimization scenarios and potential bugs introduced during optimization.

## Test Cases

### Valid Optimizations (Should Pass Verification)

1. **01_Arithmetic_Unchecked**: Uses `unchecked` blocks for arithmetic operations that are known to be safe.
2. **02_Loops_Caching**: Caches array length and uses unchecked increments in loops.
3. **03_Data_Location**: Optimizes data location (memory vs calldata) for function parameters.
4. **04_Storage_Packing**: Reorders state variables to optimize storage packing.
5. **08_Event_Emission**: Removes event emissions (valid optimization, events don't affect state).
6. **14_State_Ordering**: Reorders state variables for better storage packing (valid optimization).
7. **18_Storage_Collision**: Reorders state variables for storage packing (valid optimization).

### Bug Cases (Should Fail Verification)

8. **05_Safety_Trap**: Removes safety check (CAP limit), allowing deposits to exceed maximum.
9. **06_Reentrancy_Protection**: Removes reentrancy guard, making contract vulnerable to reentrancy attacks.
10. **07_Access_Control**: Removes `onlyOwner` modifier, allowing anyone to call protected functions.
11. **09_Return_Value**: Returns incorrect value (`false` instead of `true`).
12. **10_Zero_Address_Check**: Removes zero address validation, allowing invalid addresses.
13. **11_Overflow_Protection**: Removes MAX limit check, allowing values to exceed maximum.
14. **12_Multiple_Functions**: Removes validation check in one of multiple functions.
15. **13_Constructor_Params**: Removes constructor parameter validation.
16. **15_Bounds_Check**: Removes array bounds check, allowing array to exceed maximum size.
17. **16_Time_Validation**: Removes time validation in constructor, allowing unlock time in the past.
18. **17_Complex_State**: Removes amount validation, allowing zero deposits that break state tracking.
19. **19_Modifier_Chain**: Removes `whenNotPaused` modifier, allowing operations when paused.
20. **20_Arithmetic_Precision**: Removes amount validation, allowing zero amounts.
21. **21_Enum_Validation**: Removes enum value validation, allowing invalid enum values.
22. **22_Mapping_Bounds**: Removes key bounds check, allowing keys exceeding maximum.
23. **23_State_Machine**: Removes state check, allowing operations in invalid states.
24. **24_Overflow_Edge**: Removes MAX limit check for edge case overflow protection.
25. **25_Inheritance_Override**: Removes validation in inherited function override.
26. **26_Payable_Check**: Removes `msg.value > 0` check, allowing zero-value deposits.
27. **27_Division_Precision**: Removes division by zero and range checks.
28. **28_Nested_Struct**: Removes validation in nested struct operations.
29. **29_Cross_Function**: Removes validation breaking cross-function dependencies.
30. **30_Range_Validation**: Removes range validation (MIN <= value <= MAX).
31. **31_String_Length**: Removes string length validation.
32. **32_Modulo_Operation**: Removes modulo by zero check.
33. **33_Array_Manipulation**: Removes validation in array removal operations.
34. **34_Complex_Access**: Removes complex access control (operator/admin).
35. **35_Invariant_Break**: Removes validation breaking contract invariants.
36. **36_DelegateCall_Check**: Removes self-delegatecall check, allowing storage corruption.
37. **37_SelfDestruct_Check**: Removes balance check before selfdestruct.
38. **38_Fallback_Function**: Removes value check in fallback function.
39. **39_Library_Validation**: Removes validation when using library functions.
40. **40_Rounding_Error**: Removes rounding adjustment, causing precision loss.
41. **41_Loop_Unrolling**: Loop unrolling misses validation checks.
42. **42_ShortCircuit_Eval**: Splits condition, losing short-circuit behavior.
43. **43_Type_Casting**: Removes validation before unsafe type casting.
44. **44_MultiSig_Check**: Removes multi-signature requirement check.
45. **45_TimeLock_Validation**: Removes time lock check before withdrawal.
46. **46_Upgrade_Authorization**: Removes zero address check in upgrade function.
47. **47_Precision_Loss**: Changes operation order causing precision loss.
48. **48_Bitwise_Operation**: Removes bounds check for bitwise operations.
49. **49_Function_Selector**: Removes function selector validation.
50. **50_Calldata_Validation**: Removes calldata length validation.

## Running the Benchmark

```bash
python3 run_benchmark.py
```

The benchmark will:
1. Run verification on each test case
2. Compare results with expected outcomes
3. Generate a summary report
4. Save results to `benchmark_results.json`

## Expected Results

- **Valid optimizations** should pass verification (contracts are equivalent)
- **Bug cases** should fail verification (counterexamples found)

## Notes

- **Reentrancy_Protection**: Reentrancy bugs are difficult to detect with single-call equivalence testing, as they require multiple calls in a specific order. This case may pass even though it has a bug.
- **Event_Emission**: Events don't affect contract state, so removing them is a valid optimization that should pass verification.

