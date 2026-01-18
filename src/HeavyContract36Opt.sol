
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract36Opt {
    uint256[] public dataArray;
    mapping(uint256 => uint256) public dataMap;
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public result;
    uint256 public sum;

    constructor() {
        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            dataArray.push(i);
            dataMap[i] = i * 2;
        }
    }

    function computeSum() public {
        uint256 dataArrayLength = dataArray.length; // Cache length to save gas
        sum = 0;
        for (uint256 i = 0; i < dataArrayLength; i++) {
            uint256 dataArrayI = dataArray[i]; // Cache elements to reduce SLOADs
            for (uint256 j = 0; j < i; j++) {
                sum += dataArray[j] * (dataArrayI + dataMap[j]);
            }
        }
    }

    function factorial(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            uint256 fact = factorial(n - 1);
            result = n * fact;
            return result;
        }
    }

    function nestedLoopModification(uint256 multiplier, uint256 adder) public {
        uint256 dataArrayLength = dataArray.length; // Cache length to save gas
        for (uint256 i = 0; i < dataArrayLength; i++) {
            for (uint256 j = i; j < dataArrayLength; j++) {
                dataMap[j] = (dataArray[j] * multiplier) + adder;
            }
        }
    }

    function complexMathOperation(uint256 base, uint256 exponent) public {
        uint256 dataArrayLength = dataArray.length; // Cache length to save gas
        for (uint256 i = 0; i < dataArrayLength; i++) {
            uint256 powerResult = 1;
            for (uint256 j = 0; j < exponent; j++) {
                powerResult *= base;
            }
            dataArray[i] = powerResult + dataMap[i];
        }
    }

    function intensiveStateUpdates(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            uint256 index = i % MAX_ITERATIONS;
            // Cache values for reducing redundant access
            uint256 dataMapValue = (dataMap[index] + i) % MAX_ITERATIONS;
            uint256 dataArrayValue = (dataArray[index] * i) % MAX_ITERATIONS;
            // Directly update state to avoid unnecessary recalculations
            dataMap[index] = dataMapValue;
            dataArray[index] = dataArrayValue;
            result = (result + dataArrayValue) % MAX_ITERATIONS;
        }
    }
}
