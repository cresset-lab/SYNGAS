// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    // Optimization: Reordered state variables for storage packing
    // This is a VALID optimization - should pass verification
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

    function getSum() public view returns (uint256) {
        return uint256(a) + uint256(b) + c;
    }
}

