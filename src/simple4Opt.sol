
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract simple4Opt {
    int public counter = 18816000;
    int public x = 10;
    uint [] public array;

    // Removed constructor as counter is initialized directly

    function loop24() public {
        unchecked {
            // Using an unchecked block to save gas on overflow checks
            counter += 240; // Directly add 10 * 24 to counter
        }
    }

    function loop25(int [] calldata arr) public {
        int x_ = x; // Cache state variable x
        uint256 arr_len = arr.length; // Cache array length

        for (uint256 i = 0; i < arr_len; i++) {
            x_ += arr[i];
        }
        x = x_; // Update state variable x once
    }
}
