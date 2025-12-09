// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(bytes4 => bool) public allowedFunctions;
    
    constructor() {
        allowedFunctions[this.deposit.selector] = true;
        allowedFunctions[this.withdraw.selector] = true;
    }
    
    function execute(bytes4 selector, bytes calldata data) public {
        require(allowedFunctions[selector], "Function not allowed");
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

