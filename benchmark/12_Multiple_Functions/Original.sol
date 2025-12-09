// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public a;
    uint256 public b;
    uint256 public c;

    function setA(uint256 _a) public {
        require(_a > 0, "A must be positive");
        a = _a;
    }

    function setB(uint256 _b) public {
        require(_b > 0, "B must be positive");
        b = _b;
    }

    function setC(uint256 _c) public {
        require(_c > 0, "C must be positive");
        c = _c;
    }

    function compute() public view returns (uint256) {
        return a * b + c;
    }
}

