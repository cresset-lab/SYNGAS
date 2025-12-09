// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public value;
    
    function setValue(uint256 _value) public {
        require(_value <= type(uint128).max, "Value too large");
        value = _value;
    }
    
    function getValueAsUint128() public view returns (uint128) {
        require(value <= type(uint128).max, "Value too large");
        return uint128(value);
    }
}

