
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract simple3Opt {
    int public x = 10;
    int public counter = 18816000; // Initialize directly, no need for constructor

    function loop24() public {
        unchecked { // Reduce gas by using unchecked block
            counter += 240; // Modify counter directly without loop
        }
    }

    function loop25(int[] calldata arr) public {
        int sum = x; // Use a local variable to store computation
        uint256 arr_len = arr.length; // Cache length

        for (uint256 i = 0; i < arr_len; i++) {
            sum += arr[i];
        }

        x = sum;
    }
}
