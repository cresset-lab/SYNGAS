// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    address public recipient;
    uint256 public amount;

    // Optimization: Removed zero address check to save gas
    // BUG: Allows setting recipient to zero address

    function setRecipient(address _recipient) public {
        recipient = _recipient;
    }

    function setAmount(uint256 _amount) public {
        amount = _amount;
    }
}

