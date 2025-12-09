// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public admin;
    mapping(address => bool) public operators;
    uint256 public value;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Optimization: Removed onlyOperator modifier
    // BUG: Allows anyone to call setValue

    constructor() {
        admin = msg.sender;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }

    function addOperator(address op) public onlyAdmin {
        operators[op] = true;
    }
}

