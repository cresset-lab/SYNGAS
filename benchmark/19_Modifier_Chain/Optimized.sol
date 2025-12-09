// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public owner;
    bool public paused;
    uint256 public value;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Optimization: Removed whenNotPaused modifier to save gas
    // BUG: Allows setting value when paused

    constructor() {
        owner = msg.sender;
        paused = false;
    }

    function setValue(uint256 _value) public onlyOwner {
        value = _value;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }
}

