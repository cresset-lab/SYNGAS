// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract A {
    int public res;

    constructor(){
        // do something
        res = 23;
    }

    function foo() public pure returns(int){
        return 10;
    }

    function bar() public pure returns(int){
        return 20;
    }

    function fooBar() public returns(int){
        for(uint i=0; i<100; i++){
            res += foo();
            res += bar();
        }
        return res;
    }
}
