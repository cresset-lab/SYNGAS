
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract53Opt {

    uint256 public constant MODULUS = 1000000007;

    // Storage variables
    mapping(uint256 => uint256) public factorialResults;
    uint256[] public fibonacciResults;
    uint256 public lastFactorial;
    uint256 public sumOfPowers;

    constructor() {
        // Initializing storage variables
        lastFactorial = 1;
        sumOfPowers = 1;
        factorialResults[0] = 1;
        fibonacciResults.push(0);
        fibonacciResults.push(1);
    }

    // Calculate factorial recursively and store results
    function calculateFactorial(uint256 n) public returns (uint256) {
        if (n == 0 || n == 1) {
            return 1;
        }
        uint256 result = factorialResults[n];
        if (result == 0) {
            result = (n * calculateFactorial(n - 1)) % MODULUS;
            factorialResults[n] = result;
            lastFactorial = result;
        }
        return result;
    }

    // Compute Fibonacci sequence up to n-th term and store results
    function computeFibonacci(uint256 n) public returns (uint256) {
        uint256 length = fibonacciResults.length;
        while (length <= n) {
            fibonacciResults.push(
                (fibonacciResults[length - 1] + fibonacciResults[length - 2]) % MODULUS
            );
            length++;
        }
        return fibonacciResults[n];
    }

    // Calculate the sum of powers up to n with a base number
    function calculateSumOfPowers(uint256 base, uint256 exponent) public returns (uint256) {
        sumOfPowers = 0;
        for (uint256 i = 1; i <= exponent; i++) {
            sumOfPowers = (sumOfPowers + power(base, i)) % MODULUS;
        }
        return sumOfPowers;
    }

    // Helper function to calculate power recursively
    function power(uint256 base, uint256 exp) internal pure returns (uint256) {
        if (exp == 0) {
            return 1;
        }
        uint256 half = power(base, exp / 2);
        uint256 halfSquared = (half * half) % MODULUS;
        return (exp % 2 == 0) ? halfSquared : (halfSquared * base) % MODULUS;
    }

    // Perform a nested loop calculation, storing results for each iteration
    function nestedLoopCalculation(uint256 layers) public returns (uint256) {
        uint256 total = 1;
        for (uint256 i = 1; i <= layers; i++) {
            uint256 layerSum = 0;
            for (uint256 j = 1; j <= i; j++) {
                layerSum = (layerSum + j) % MODULUS;
            }
            total = (total * layerSum) % MODULUS;
            lastFactorial = calculateFactorial(total % 10); // Randomly link to another function for more complexity
        }
        return total;
    }
}
