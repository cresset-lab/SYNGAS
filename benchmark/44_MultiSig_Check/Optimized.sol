// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(address => bool) public signers;
    mapping(bytes32 => mapping(address => bool)) public approvals;
    uint256 public requiredSignatures = 2;
    
    constructor() {
        signers[msg.sender] = true;
    }
    
    function approve(bytes32 txHash) public {
        require(signers[msg.sender], "Not a signer");
        approvals[txHash][msg.sender] = true;
    }
    
    // Optimization: Removed signature count check
    // BUG: Allows execution without required signatures
    function execute(bytes32 txHash) public {
        // Removed validation
    }
}

