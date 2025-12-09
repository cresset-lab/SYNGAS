// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public owner;
    uint256 public balance;
    
    constructor() {
        owner = msg.sender;
    }
    
    receive() external payable {
        balance += msg.value;
    }
    
    // Optimization: Removed balance check
    // BUG: Allows selfdestruct even when balance is zero
    function destroy() public {
        require(msg.sender == owner, "Not owner");
        selfdestruct(payable(owner));
    }
}

