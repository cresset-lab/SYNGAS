// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract79Opt {
    
    uint256 public result;
    uint256[] public data;
    mapping(uint256 => uint256) public factorialResults;

    constructor() {
        result = 0;
    }

    function computeFactorial(uint256 n) public {
        uint256 fact = 1;
        for (uint256 i = 1; i <= n; i++) {
            fact *= i;
            factorialResults[i] = fact;
        }
        result = fact;
    }

    function processArray(uint256[] memory inputArray) public {
        uint256 inputArray_len = inputArray.length;
        uint256 sum = 0;
        for (uint256 i = 0; i < inputArray_len; i++) {
            uint256 inputArray_i = inputArray[i];
            for (uint256 j = 0; j < inputArray_len; j++) {
                if (i != j) {
                    sum += inputArray_i * inputArray[j];
                }
            }
        }
        data = inputArray;
        result = sum;
    }

    function complexCalculation(uint256 limit) public {
        uint256 total = 0;
        for (uint256 i = 1; i <= limit; i++) {
            uint256 i_squared = i * i;
            uint256 end_j = i + 1;
            for (uint256 j = 1; j < end_j; j++) {
                uint256 j_squared = j * j;
                total += (i_squared + j_squared) % (i + j);
            }
        }
        result = total;
    }

    function recursiveFib(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        }
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 2; i <= n; i++) {
            uint256 next = a + b;
            a = b;
            b = next;
        }
        result = b;
        return b;
    }

    function heavyWhileLoop(uint256 iterations) public {
        uint256 total = 0;
        for (uint256 i = 0; i < iterations; i++) {
            total += i * i;
        }
        result = total;
    }
}