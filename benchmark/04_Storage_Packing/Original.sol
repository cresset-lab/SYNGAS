// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    // Layout:
    // Slot 0: a (64 bits)
    // Slot 1: b (256 bits) - Cannot pack with 'a'
    // Slot 2: c (64 bits) - Cannot pack with 'b'
    // Total: 3 slots
    struct Data {
        uint64 a;
        uint256 b;
        uint64 c;
    }
    
    Data public data;

    function set(uint64 _a, uint256 _b, uint64 _c) public {
        data.a = _a;
        data.b = _b;
        data.c = _c;
    }
}