// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public result;

    function divide(uint256 a, uint256 b) public {
        require(b > 0, "Division by zero");
        require(a >= b, "Numerator must be >= denominator");
        result = a / b;
    }

    function getResult() public view returns (uint256) {
        return result;
    }
}

