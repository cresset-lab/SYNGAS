// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract37Opt {
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public constant ARRAY_SIZE = 10;

    uint256[] public results;
    mapping(address => uint256) public userCalculations;
    uint256 public globalSum;

    event CalculationPerformed(address indexed user, uint256 result);

    constructor() {
        results = new uint256[](ARRAY_SIZE);
    }

    function computeFibonacci(uint256 n) public returns (uint256) {
        require(n < 50, "Number too large for computation");
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 2; i <= n; i++) {
            uint256 c = a + b;
            a = b;
            b = c;
        }
        userCalculations[msg.sender] = b;
        return b;
    }
    
    function computeNestedLoops(uint256 iterations) public returns (uint256) {
        require(iterations <= MAX_ITERATIONS, "Too many iterations");
        uint256 sum = 0;
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < ARRAY_SIZE; j++) {
                uint256 result = (i + j) ** 2;
                results[j] = result;
                sum += result;
            }
        }
        globalSum = sum;
        emit CalculationPerformed(msg.sender, sum);
        return sum;
    }

    function complexMappingUpdate(address[] memory addresses) public {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            address user = addresses[i];
            for (uint256 j = 0; j < ARRAY_SIZE; j++) {
                uint256 fibValue = computeFibonacci(j);
                userCalculations[user] = fibValue + i;
            }
        }
    }

    function computeFactorial(uint256 n) public returns (uint256) {
        require(n <= 20, "Number too large for recursion");
        uint256 result = _factorial(n);
        userCalculations[msg.sender] = result;
        return result;
    }

    function _factorial(uint256 n) internal pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        return n * _factorial(n - 1);
    }

    function heavyStateModification(uint256 runs) public {
        require(runs <= MAX_ITERATIONS, "Exceeds max iteration limit");
        uint256 step = runs % ARRAY_SIZE;
        for (uint256 i = 0; i < runs; i++) {
            results[i % ARRAY_SIZE] = computeFibonacci(i % 20);
        }
    }
}