// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    // Optimization: Reordered for storage packing
    // This is a VALID optimization - should pass
    uint128 public a;
    uint256 public c;  // Moved before b
    uint128 public b;

    function setA(uint128 _a) public {
        a = _a;
    }

    function setB(uint128 _b) public {
        b = _b;
    }

    function setC(uint256 _c) public {
        c = _c;
    }

    function getValues() public view returns (uint128, uint128, uint256) {
        return (a, b, c);
    }
}

