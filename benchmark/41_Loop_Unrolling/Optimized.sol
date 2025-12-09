// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256[10] public values;
    uint256 public sum;
    
    // Optimization: Unrolled loop, but missed validation
    // BUG: Allows values >= 1000, breaking the constraint
    function setValues(uint256[10] memory _values) public {
        values[0] = _values[0];
        values[1] = _values[1];
        values[2] = _values[2];
        values[3] = _values[3];
        values[4] = _values[4];
        values[5] = _values[5];
        values[6] = _values[6];
        values[7] = _values[7];
        values[8] = _values[8];
        values[9] = _values[9];
        updateSum();
    }
    
    function updateSum() internal {
        sum = 0;
        for (uint256 i = 0; i < 10; i++) {
            sum += values[i];
        }
    }
}

