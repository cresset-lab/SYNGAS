// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public total;
    uint256 public count;
    
    function addValue(uint256 value) public {
        require(value > 0, "Value must be positive");
        total += value;
        count++;
    }
    
    function getAverage() public view returns (uint256) {
        require(count > 0, "No values");
        // Proper rounding: add half of divisor before dividing
        return (total + count / 2) / count;
    }
}

