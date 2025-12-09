// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public value;
    uint256 public constant MIN = 10;
    uint256 public constant MAX = 1000;

    function setValue(uint256 _value) public {
        require(_value >= MIN && _value <= MAX, "Value out of range");
        value = _value;
    }

    function getValue() public view returns (uint256) {
        return value;
    }
}

