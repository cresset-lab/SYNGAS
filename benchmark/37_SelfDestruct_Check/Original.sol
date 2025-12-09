// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public owner;
    uint256 public balance;
    
    constructor() {
        owner = msg.sender;
    }
    
    receive() external payable {
        balance += msg.value;
    }
    
    function destroy() public {
        require(msg.sender == owner, "Not owner");
        require(balance > 0, "No balance");
        selfdestruct(payable(owner));
    }
}

