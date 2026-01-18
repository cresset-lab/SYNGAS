// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TargetOpt {
    // State variables
    uint256 public total;
    uint256[] public data;

    // Helper to populate data for testing
    function addData(uint256[] memory _values) public {
        uint256 _values_len = _values.length;
        for (uint256 i = 0; i < _values_len; ) {
            data.push(_values[i]);
            unchecked { ++i; }
        }
    }

    // --- The Function to Optimize ---
    // This function is optimized for gas efficiency.
    function doSomethingExpensive(uint256 limit) public returns (uint256) {
        uint256 sum = 0; // Use a local variable to accumulate the sum
        uint256 data_len = data.length;
        
        for (uint256 i = 0; i < data_len; ) {
            if (i < limit) {
                sum += data[i];
            }
            unchecked { ++i; }
        }

        total = sum; // Assign the accumulated result to the state variable once

        return total;
    }
}