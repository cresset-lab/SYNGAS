// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public total;
    uint256 public divisor = 1000;
    
    // Optimization: Changed order of operations
    // BUG: Division before multiplication causes precision loss
    function calculate(uint256 value) public {
        require(value > 0, "Value must be positive");
        total = (value / divisor) * 100;
    }
    
    function getResult() public view returns (uint256) {
        return total;
    }
}

