// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(uint256 => uint256) public data;
    uint256 public constant MAX_KEY = 1000;

    // Optimization: Removed key bounds check
    // BUG: Allows keys exceeding MAX_KEY
    function set(uint256 key, uint256 value) public {
        data[key] = value;
    }

    function get(uint256 key) public view returns (uint256) {
        return data[key];
    }
}

