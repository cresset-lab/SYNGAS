// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public owner;
    bool public paused;
    uint256 public value;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        paused = false;
    }

    function setValue(uint256 _value) public onlyOwner whenNotPaused {
        value = _value;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }
}

