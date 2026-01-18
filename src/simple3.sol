// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract simple3 {
    int public x = 10;
    int public counter;
    constructor(){
        counter = 10 * 20*30*56 *56;
    }

    function loop24() public {
        for (uint256 i = 0; i < 24; i++) {
            counter += 10;
        }
    }

    function loop25(int [] memory arr) public {
        for (uint256 i = 0; i < arr.length; i++) {
            x += arr[i];
        }
    }
}
