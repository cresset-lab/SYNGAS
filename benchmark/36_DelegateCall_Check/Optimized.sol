// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public owner;
    uint256 public value;
    
    constructor() {
        owner = msg.sender;
    }
    
    function setValue(uint256 _value) public {
        require(msg.sender == owner, "Not owner");
        value = _value;
    }
    
    // Optimization: Removed self-delegatecall check
    // BUG: Allows delegatecall to self, which can lead to storage corruption
    function executeDelegateCall(address target, bytes calldata data) public {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = target.delegatecall(data);
        require(success, "Delegatecall failed");
    }
}

