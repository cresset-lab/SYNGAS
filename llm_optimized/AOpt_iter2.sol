// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AOpt {
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
        int sum = 0;
        for(uint i=0; i<100; i++){
            sum += foo();
            sum += bar();
        }
        res += sum;
        return res;
    }
}