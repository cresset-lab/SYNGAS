// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a + b >= a, "Addition overflow");
        return a + b;
    }
}

contract Original {
    using SafeMath for uint256;
    uint256 public total;
    
    function addToTotal(uint256 amount) public {
        require(amount > 0, "Amount must be positive");
        total = total.add(amount);
    }
}

