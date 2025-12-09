// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public owner;
    uint256 public value;
    
    constructor() {
        owner = msg.sender;
    }
    
    function setValue(uint256 _value) public {
        require(msg.sender == owner, "Not owner");
        value = _value;
    }
    
    function executeDelegateCall(address target, bytes calldata data) public {
        require(msg.sender == owner, "Not owner");
        require(target != address(this), "Cannot delegatecall to self");
        (bool success, ) = target.delegatecall(data);
        require(success, "Delegatecall failed");
    }
}

