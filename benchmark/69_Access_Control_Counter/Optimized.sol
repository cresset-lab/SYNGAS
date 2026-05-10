// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public owner;
    uint256 public x;

    constructor() {
        owner = msg.sender;
    }

    function bump() public {
        x += 1;
    }
}
