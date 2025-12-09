// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    struct Inner {
        uint256 value;
        bool active;
    }
    
    struct Outer {
        Inner inner;
        uint256 timestamp;
    }
    
    mapping(address => Outer) public data;

    function setData(address user, uint256 value) public {
        require(value > 0, "Value must be positive");
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

