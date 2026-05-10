// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    bool public locked;

    function enter() public {
        locked = true;
    }

    function leave() public {
        locked = false;
    }
}
