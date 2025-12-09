// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    address public recipient;
    uint256 public amount;

    function setRecipient(address _recipient) public {
        require(_recipient != address(0), "Zero address not allowed");
        recipient = _recipient;
    }

    function setAmount(uint256 _amount) public {
        amount = _amount;
    }
}

