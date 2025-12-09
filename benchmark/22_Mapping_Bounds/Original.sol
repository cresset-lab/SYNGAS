// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(uint256 => uint256) public data;
    uint256 public constant MAX_KEY = 1000;

    function set(uint256 key, uint256 value) public {
        require(key <= MAX_KEY, "Key exceeds maximum");
        data[key] = value;
    }

    function get(uint256 key) public view returns (uint256) {
        return data[key];
    }
}

