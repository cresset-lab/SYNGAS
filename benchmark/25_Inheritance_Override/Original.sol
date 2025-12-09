// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Base {
    uint256 public value;
    
    function setValue(uint256 _value) public virtual {
        require(_value > 0, "Value must be positive");
        value = _value;
    }
}

contract Original is Base {
    function setValue(uint256 _value) public override {
        require(_value > 0, "Value must be positive");
        value = _value;
    }
}

