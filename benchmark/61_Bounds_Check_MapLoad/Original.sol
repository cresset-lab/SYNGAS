// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public constant MAX_KEY = 64;
    mapping(uint256 => uint256) private _m;

    function setVal(uint256 k, uint256 v) public {
        require(k < MAX_KEY, "Bounds_Check");
        _m[k] = v;
    }

    function load(uint256 k) public view returns (uint256) {
        require(k < MAX_KEY, "Bounds_Check");
        return _m[k];
    }
}
