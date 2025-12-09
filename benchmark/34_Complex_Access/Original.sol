// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public admin;
    mapping(address => bool) public operators;
    uint256 public value;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender] || msg.sender == admin, "Not operator");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setValue(uint256 _value) public onlyOperator {
        value = _value;
    }

    function addOperator(address op) public onlyAdmin {
        operators[op] = true;
    }
}

