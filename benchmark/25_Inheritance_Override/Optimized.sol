// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Base {
    uint256 public value;
    
    function setValue(uint256 _value) public virtual {
        require(_value > 0, "Value must be positive");
        value = _value;
    }
}

contract Optimized is Base {
    // Optimization: Removed validation in override
    // BUG: Allows setting value to 0
    function setValue(uint256 _value) public override {
        value = _value;
    }
}

