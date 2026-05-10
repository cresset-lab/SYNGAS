// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public owner;
    uint256 public x;

    constructor() {
        owner = msg.sender;
    }

    function bump() public {
        require(msg.sender == owner, "Access_Control");
        x += 1;
    }
}
