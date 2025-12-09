// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public value;
    
    function setValue(uint256 _value) public {
        require(_value <= type(uint128).max, "Value too large");
        value = _value;
    }
    
    // Optimization: Removed validation before cast
    // BUG: Unsafe cast can truncate value if it exceeds uint128.max
    function getValueAsUint128() public view returns (uint128) {
        return uint128(value);
    }
}

