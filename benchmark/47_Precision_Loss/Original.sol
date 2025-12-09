// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public total;
    uint256 public divisor = 1000;
    
    function calculate(uint256 value) public {
        require(value > 0, "Value must be positive");
        // Multiply first to preserve precision, then divide
        total = (value * 100) / divisor;
    }
    
    function getResult() public view returns (uint256) {
        return total;
    }
}

