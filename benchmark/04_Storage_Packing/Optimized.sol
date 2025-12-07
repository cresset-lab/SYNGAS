// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    // Layout:
    // Slot 0: a (64 bits) + c (64 bits) = 128 bits used
    // Slot 1: b (256 bits)
    // Total: 2 slots
    struct Data {
        uint64 a;
        uint64 c; // Moved up to pack with 'a'
        uint256 b;
    }
    
    Data public data;

    function set(uint64 _a, uint256 _b, uint64 _c) public {
        data.a = _a;
        data.b = _b;
        data.c = _c;
    }
}