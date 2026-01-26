// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AOpt {
    int public res = 23;

    function foo() pure returns(int){
        return 10;
    }

    function bar() pure returns(int){
        return 20;
    }

    function fooBar() returns(int) {
        uint i = 0;
        while(i < 100) {
            unchecked { res += foo(); }
            unchecked { res += bar(); }
            unchecked { ++i; }
        }
        return res;
    }
}