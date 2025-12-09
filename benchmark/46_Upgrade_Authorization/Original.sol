// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public admin;
    address public implementation;
    
    constructor() {
        admin = msg.sender;
    }
    
    function upgrade(address newImplementation) public {
        require(msg.sender == admin, "Not admin");
        require(newImplementation != address(0), "Invalid implementation");
        implementation = newImplementation;
    }
}

