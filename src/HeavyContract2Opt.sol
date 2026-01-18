// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract2Opt {
    string public name = "HeavyToken";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**18;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    uint256[] private dataPoints;
    mapping(uint256 => uint256) private indexMap;
    uint256 private counter;
    uint256[] private complexArray;
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        counter = 0;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        uint256 length = dataPoints.length;
        uint256 balanceSender = balanceOf[msg.sender];
        for (uint256 i = 0; i < length; i++) {
            balanceSender -= dataPoints[i] % (_value + 1);
        }
        balanceSender -= _value;
        
        balanceOf[msg.sender] = balanceSender;
        balanceOf[_to] += _value;
        
        complexCalculation(_value);

        return true;
    }
    
    function complexCalculation(uint256 seed) private {
        uint256 newCounter = counter;
        for (uint256 i = 0; i < 10; i++) {
            uint256 sum = seed + i;
            for (uint256 j = 0; j < 10; j++) {
                newCounter += sum * j;
            }
        }
        counter = newCounter;
    }

    function addData(uint256 value) public {
        dataPoints.push(value);
        indexMap[value] = dataPoints.length - 1;
    }

    function processData() public {
        uint256 length = dataPoints.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 base = dataPoints[i];
            for (uint256 j = i; j < length; j++) {
                complexArray.push(base + dataPoints[j]);
            }
        }
        
        delete complexArray;
    }

    function recursivePattern(uint256 n) public returns (uint256) {
        require(n < 10, "Too large for recursion demo");
        return n == 0 ? 1 : n * recursivePattern(n - 1);
    }

    function iterateBalances() public view returns (uint256 total) {
        for (uint256 i = 0; i < 256; i++) {
            total += balanceOf[address(uint160(i))];
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        uint256 newCounter = counter;
        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < 5; j++) {
                newCounter += i * j;
            }
        }
        counter = newCounter;

        return true;
    }
}