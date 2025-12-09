// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public count;
    
    event CountUpdated(uint256 oldCount, uint256 newCount);

    function increment() public {
        uint256 oldCount = count;
        count++;
        emit CountUpdated(oldCount, count);
    }

    function decrement() public {
        uint256 oldCount = count;
        count--;
        emit CountUpdated(oldCount, count);
    }
}

