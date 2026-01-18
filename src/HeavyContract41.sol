// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract41 {
    uint256[] public numbers;
    mapping(address => uint256) public balances;
    mapping(uint256 => uint256) public numberIndex;
    uint256 public numberCounter;

    constructor() {
        numberCounter = 0;
    }

    // Add numbers to the array and update mappings
    function addNumbers(uint256[] memory nums) public {
        for (uint256 i = 0; i < nums.length; i++) {
            numbers.push(nums[i]);
            numberIndex[nums[i]] = numbers.length - 1;
            numberCounter++;
        }
    }

    // Perform a heavy computation - prime number counting
    function countPrimes(uint256 from, uint256 to) public view returns (uint256) {
        uint256 primeCount = 0;
        for (uint256 i = from; i <= to; i++) {
            if (isPrime(i)) {
                primeCount++;
            }
        }
        return primeCount;
    }

    // Check if a number is prime
    function isPrime(uint256 num) internal pure returns (bool) {
        if (num < 2) return false;
        for (uint256 i = 2; i * i <= num; i++) {
            if (num % i == 0) return false;
        }
        return true;
    }

    // Add balance to a user account
    function addBalance(address user, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        balances[user] += amount;
    }

    // Validate numbers and perform a recursive operation
    function validateAndMultiply(uint256 multiplier) public {
        for (uint256 i = 0; i < numbers.length; i++) {
            if (validateNumber(numbers[i])) {
                multiply(numbers[i], multiplier);
            }
        }
    }

    // Validate a number based on arbitrary complex checks
    function validateNumber(uint256 num) internal pure returns (bool) {
        return num % 2 == 0 || num % 5 == 0;
    }

    // Multiply a number with recursion
    function multiply(uint256 num, uint256 times) internal pure returns (uint256) {
        if (times == 0) return 0;
        return num + multiply(num, times - 1);
    }

    // Resize the numbers array dynamically
    function sliceArray(uint256 newSize) public {
        require(newSize <= numbers.length, "New size exceeds current array size");
        while (numbers.length > newSize) {
            numbers.pop();
        }
    }

    // A non-trivial loop operation with storage updates
    function updateNumberIndex() public {
        for (uint256 i = 0; i < numbers.length; i++) {
            numberIndex[numbers[i]] = i;
        }
    }

    // Function to reset the state of the contract
    function resetContract() public {
        delete numbers;
        numberCounter = 0;
    }
}