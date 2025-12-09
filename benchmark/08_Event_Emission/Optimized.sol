// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public count;
    
    // Optimization: Removed events to save gas
    // This is a valid optimization but changes observable behavior

    function increment() public {
        count++;
    }

    function decrement() public {
        count--;
    }
}

