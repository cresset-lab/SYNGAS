// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract55Opt {
    uint256 public heavyCounter;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public validators;
    uint256[] public data;

    // Recursive Fibonacci with storage
    function recursiveFibonacci(uint256 n) public pure returns (uint256) {
        if (n <= 1) {
            return n;
        }
        return recursiveFibonacci(n - 1) + recursiveFibonacci(n - 2);
    }

    // Update balances with heavy computation logic
    function updateBalanceWithHeavyLogic(address[] calldata accounts, uint256[] calldata amounts) public {
        require(accounts.length == amounts.length, "Array lengths must match");
        uint256 accounts_len = accounts.length;
        for (uint256 i = 0; i < accounts_len; i++) {
            uint256 amount = amounts[i];
            address account = accounts[i];
            balances[account] += amount;
        }
    }

    // Complex validator check with nested loops and storage updates
    function complexValidatorCheck(address[] calldata accounts) public view returns (bool) {
        uint256 accounts_len = accounts.length;
        uint256 data_len = data.length;
        for (uint256 i = 0; i < accounts_len; i++) {
            if (validators[accounts[i]] == 0) {
                return false;
            }
            uint256 accountValidator = validators[accounts[i]];
            for (uint256 j = 0; j < data_len; j++) {
                uint256 dataValue = data[j];
                if (dataValue % 2 == 0) {
                    accountValidator += dataValue;
                } else {
                    accountValidator -= dataValue;
                }
            }
        }
        return true;
    }

    // Heavy calculation that triggers additional state changes
    function heavyCalculation(uint256[] calldata numbers) public returns (uint256) {
        uint256 total = 0;
        uint256 numbers_len = numbers.length;
        for (uint256 i = 0; i < numbers_len; i++) {
            uint256 sum = 0;
            uint256 num = numbers[i];
            for (uint256 j = 0; j < num; j++) {
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