// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(bytes4 => bool) public allowedFunctions;
    
    constructor() {
        allowedFunctions[this.deposit.selector] = true;
        allowedFunctions[this.withdraw.selector] = true;
    }
    
    // Optimization: Removed selector validation
    // BUG: Allows calling any function, bypassing access control
    function execute(bytes4 selector, bytes calldata data) public {
        (bool success, ) = address(this).call(abi.encodePacked(selector, data));
        require(success, "Call failed");
    }
    
    function deposit() public payable {
        // Deposit logic
    }
    
    function withdraw(uint256 amount) public {
        // Withdraw logic
    }
}

