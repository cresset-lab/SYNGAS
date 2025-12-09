// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public admin;
    address public implementation;
    
    constructor() {
        admin = msg.sender;
    }
    
    // Optimization: Removed zero address check
    // BUG: Allows setting implementation to zero address
    function upgrade(address newImplementation) public {
        require(msg.sender == admin, "Not admin");
        implementation = newImplementation;
    }
}

