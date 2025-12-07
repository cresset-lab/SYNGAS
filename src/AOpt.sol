
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AOpt {
    int public res = 23;

    constructor() {
        // do something
    }

    function foo() internal pure returns(int) {
        return 10;
    }

    function bar() internal pure returns(int) {
        return 20;
    }

    function fooBar() public returns(int) {
        int fooValue = foo();
        int barValue = bar();
        int res_ = res;
        
        for (uint i = 0; i < 100; i++) {
            res_ += fooValue;
            res_ += barValue;
        }
        
        res = res_;
        return res;
    }
}
