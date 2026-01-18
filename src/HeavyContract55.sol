// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract55 {
    uint256 public heavyCounter;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public validators;
    uint256[] public data;

    // Recursive Fibonacci with storage
    function recursiveFibonacci(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        }
        // Store intermediate results to increase gas usage
        uint256 a = recursiveFibonacci(n - 1);
        uint256 b = recursiveFibonacci(n - 2);
        return a + b;
    }

    // Update balances with heavy computation logic
    function updateBalanceWithHeavyLogic(address[] memory accounts, uint256[] memory amounts) public {
        require(accounts.length == amounts.length, "Array lengths must match");
        for (uint256 i = 0; i < accounts.length; i++) {
            for (uint256 j = 0; j < amounts[i]; j++) {
                balances[accounts[i]]++;
            }
        }
    }

    // Complex validator check with nested loops and storage updates
    function complexValidatorCheck(address[] memory accounts) public returns (bool) {
        bool isValid = true;
        for (uint256 i = 0; i < accounts.length; i++) {
            if (validators[accounts[i]] == 0) {
                isValid = false;
            }
            for (uint256 j = 0; j < data.length; j++) {
                if (data[j] % 2 == 0) {
                    validators[accounts[i]] += data[j];
                } else {
                    validators[accounts[i]] -= data[j];
                }
            }
        }
        return isValid;
    }

    // Heavy calculation that triggers additional state changes
    function heavyCalculation(uint256[] calldata numbers) public returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < numbers[i]; j++) {
                sum += j;
            }
            total += sum;
        }
        heavyCounter += total;
        return total;
    }

    // Recursive factorial with storage writes
    function recursiveFactorial(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 1;
        }
        uint256 result = n * recursiveFactorial(n - 1);
        heavyCounter += result;
        return result;
    }

    // Add data to storage array
    function addData(uint256 value) public {
        data.push(value);
    }
}