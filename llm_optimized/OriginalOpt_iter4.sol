// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public owner;
    uint256 private _value;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setValue(uint256 newValue) external onlyOwner {
        _value = newValue;
    }

    function getValue() external view returns (uint256) {
        return _value;
    }
}