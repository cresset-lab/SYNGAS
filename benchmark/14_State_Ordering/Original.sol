// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint128 public a;
    uint128 public b;
    uint256 public c;

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

