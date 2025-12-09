// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public total;
    uint256 public count;
    
    function addValue(uint256 value) public {
        require(value > 0, "Value must be positive");
        total += value;
        count++;
    }
    
    // Optimization: Removed rounding adjustment
    // BUG: Truncates instead of rounding, causing precision loss
    function getAverage() public view returns (uint256) {
        require(count > 0, "No values");
        return total / count;
    }
}

