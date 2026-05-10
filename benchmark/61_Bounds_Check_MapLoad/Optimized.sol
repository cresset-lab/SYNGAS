// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public constant MAX_KEY = 64;
    mapping(uint256 => uint256) private _m;

    function setVal(uint256 k, uint256 v) public {
        _m[k] = v;
    }

    function load(uint256 k) public view returns (uint256) {
        return _m[k];
    }
}
