// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract68Opt {
    uint256 public iterationCount;
    mapping(uint256 => uint256) public results;
    uint256[] public dataArray;
    uint256 public constant MAX_ITERATIONS = 1000;

    constructor() {
        // Initialize dataArray with some values
        for (uint256 i = 0; i < 10; ) {
            dataArray.push(i);
            unchecked { i++; }
        }
    }

    // A function with a recursive pattern and heavy use of storage
    function heavyRecursiveCalculation(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 1;
        }

        uint256 result = heavyRecursiveCalculation(n - 1) * n;
        // Store result in mapping for later use
        results[n] = result;

        return result;
    }

    // A function with nested loops performing intense calculations
    function nestedLoopCalculation(uint256 start, uint256 end) public returns (uint256) {
        require(start < end, "Start must be less than end");

        uint256 sum = 0;
        uint256 dataArray_len = dataArray.length;
        for (uint256 i = start; i < end; ) {
            for (uint256 j = 0; j < dataArray_len; ) {
                uint256 dataArray_temp = dataArray[j];
                sum += dataArray_temp * i;
                dataArray[j] = sum; // Frequent storage updates
                unchecked { j++; }
            }
            unchecked { i++; }
        }

        iterationCount += end - start;
        return sum;
    }

    // A function with multiple iterations and heavy computations
    function computeFactorial(uint256 num) public returns (uint256) {
        require(num < 20, "Number too large; would cause overflow");
        uint256 factorial = 1;
        for (uint256 i = 1; i <= num; ) {
            factorial *= i;
            results[i] = factorial; // Store intermediate results
            unchecked { i++; }
        }
        return factorial;
    }

    // A while loop with intensive computation
    function heavyWhileLoop(uint256 targetSum) public returns (uint256) {
        uint256 total = 0;
        uint256 i = 0;
        uint256 dataArray_len = dataArray.length;
        while (total < targetSum && i < MAX_ITERATIONS) {
            for (uint256 j = 0; j < dataArray_len; ) {
                total += dataArray[j] * (i + 1);
                if (total >= targetSum) break; // Break if target sum is reached
                unchecked { j++; }
            }
            unchecked { i++; }
        }

        // Store the iteration count in storage
        iterationCount = i;
        return total;
    }

    // Complex mathematical operation with iterative storage updates
    function complexMathOperation(uint256 x, uint256 y) public returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < x; ) {
            for (uint256 j = 0; j < y; ) {
                result += (i + 1) * (j + 1);
                // Update mapping with results of computations
                results[i * y + j] = result;
                unchecked { j++; }
            }
            unchecked { i++; }
        }
        iterationCount += x * y;
        return result;
    }
}