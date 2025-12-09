// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256[10] public values;
    uint256 public sum;
    
    function setValues(uint256[10] memory _values) public {
        for (uint256 i = 0; i < 10; i++) {
            require(_values[i] < 1000, "Value too large");
            values[i] = _values[i];
        }
        updateSum();
    }
    
    function updateSum() internal {
        sum = 0;
        for (uint256 i = 0; i < 10; i++) {
            sum += values[i];
        }
    }
}

