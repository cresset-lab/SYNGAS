// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract92Opt {
    
    uint256 public constant ITERATIONS = 100;
    mapping(address => uint256[]) public userCalculations;
    uint256[] public results;
    uint256 public totalCalculations;
    
    // Hash calculation in a loop
    function computeHashes(uint256 input) public {
        uint256 lastHash = input;
        uint256 timestamp = block.timestamp;
        address contractAddress = address(this);
        for (uint256 i = 0; i < ITERATIONS; i++) {
            lastHash = uint256(keccak256(abi.encodePacked(lastHash, timestamp, contractAddress, i)));
            results.push(lastHash);
        }
        totalCalculations += ITERATIONS;
    }
    
    // Nested loops with updates and calculations
    function nestedCalculations(uint256[] calldata inputs) public {
        uint256 results_len = results.length;
        uint256 inputs_len = inputs.length;
        uint256 sum = 0;
        for (uint256 i = 0; i < inputs_len; i++) {
            uint256 input = inputs[i];
            for (uint256 j = 0; j < results_len; j++) {
                sum += (input * results[j]) / (i + 1);
                userCalculations[msg.sender].push(sum);
            }
        }
        totalCalculations += inputs_len * results_len;
    }
    
    // Recursive computation
    function recursiveFactorial(uint256 n) public returns (uint256) {
        if (n == 0) {
            results.push(1);
            return 1;
        } else {
            uint256 result = n * recursiveFactorial(n - 1);
            results.push(result);
            return result;
        }
    }
    
    // Storage-intensive operation with loop
    function intensiveStorageOperation(uint256 start, uint256 end) public {
        require(start < end, "Invalid range");
        uint256 iterations = ITERATIONS;
        for (uint256 i = start; i < end; i++) {
            for (uint256 j = 0; j < iterations; j++) {
                userCalculations[msg.sender].push(i + j);
            }
        }
        totalCalculations += (end - start) * iterations;
    }
    
    // Complex computation involving multiple state updates
    function complexComputation(uint256 base, uint256 iterations) public {
        uint256 result = base;
        for (uint256 i = 0; i < iterations; i++) {
            result = (result * 3 + i) % 1000000007;
            results.push(result);
            totalCalculations++;
        }
    }
}