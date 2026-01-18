// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract59 {
    string public name = "HeavyToken";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    struct Account {
        uint256 balance;
        mapping(uint256 => uint256) complexData;
    }

    mapping(address => Account) public accounts;

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        // Initialize complex data
        for (uint256 i = 0; i < 100; i++) {
            accounts[msg.sender].complexData[i] = i;
        }
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        recursiveComplexUpdate(msg.sender);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        recursiveComplexUpdate(_from);
        return true;
    }

    function recursiveComplexUpdate(address _account) internal {
        // Recursive updates in a complex manner
        uint256 iterations = 10;
        complexRecursiveFunction(_account, iterations);
    }

    function complexRecursiveFunction(address _account, uint256 _iterations) internal {
        if (_iterations == 0) return;
        for (uint256 i = 0; i < 50; i++) {
            accounts[_account].complexData[i] += accounts[_account].complexData[i] * 2 + i;
        }
        complexRecursiveFunction(_account, _iterations - 1);
    }

    function heavyComputationOnData(address _account) public returns (uint256) {
        uint256 result;
        for (uint256 i = 0; i < 10; i++) {
            result += computeFactorial(accounts[_account].complexData[i % 50] % 10);
        }
        return result;
    }

    function computeFactorial(uint256 _num) internal pure returns (uint256) {
        if (_num == 0 || _num == 1) return 1;
        return _num * computeFactorial(_num - 1);
    }

    function gasHeavyLoopOperation(uint256 _limit) public {
        uint256 sum;
        for (uint256 i = 0; i < _limit; i++) {
            for (uint256 j = 0; j < 20; j++) {
                sum += i * j;
                accounts[msg.sender].complexData[j % 50] += sum;
            }
        }
    }

    function performNestedCalculations(uint256 _depth) public returns (uint256) {
        return nestedCalculation(msg.sender, _depth);
    }

    function nestedCalculation(address _account, uint256 _depth) internal returns (uint256) {
        if (_depth == 0) return accounts[_account].balance;
        uint256 temp = 0;
        for (uint256 i = 0; i < 5; i++) {
            temp += nestedCalculation(_account, _depth - 1) + accounts[_account].complexData[i % 50];
        }
        accounts[_account].balance += temp % 100;
        return temp;
    }
}