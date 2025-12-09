// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    struct Inner {
        uint256 value;
        bool active;
    }
    
    struct Outer {
        Inner inner;
        uint256 timestamp;
    }
    
    mapping(address => Outer) public data;

    // Optimization: Removed value validation
    // BUG: Allows setting value to 0
    function setData(address user, uint256 value) public {
        data[user] = Outer({
            inner: Inner({
                value: value,
                active: true
            }),
            timestamp: block.timestamp
        });
    }

    function getValue(address user) public view returns (uint256) {
        return data[user].inner.value;
    }
}

