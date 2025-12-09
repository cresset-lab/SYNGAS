// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public value;
    uint256 public constant MIN = 10;
    uint256 public constant MAX = 1000;

    // Optimization: Removed range validation
    // BUG: Allows values outside [MIN, MAX] range
    function setValue(uint256 _value) public {
        value = _value;
    }

    function getValue() public view returns (uint256) {
        return value;
    }
}

