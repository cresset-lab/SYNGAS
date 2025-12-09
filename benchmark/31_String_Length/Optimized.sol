// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    string public data;
    uint256 public constant MAX_LENGTH = 100;

    // Optimization: Removed length validation
    // BUG: Allows strings exceeding MAX_LENGTH
    function setData(string memory _data) public {
        data = _data;
    }

    function getData() public view returns (string memory) {
        return data;
    }
}

