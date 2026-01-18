// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract59Opt {
    string public constant name = "HeavyToken";
    string public constant symbol = "HTK";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    struct Account {
        uint256 balance;
        mapping(uint256 => uint256) complexData;
    }
    
    mapping(address => Account) public accounts;
    
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        // Initialize complex data
        uint256[100] memory initialData;
        for (uint256 i = 0; i < 100; i++) {
            initialData[i] = i;
        }
        for (uint256 i = 0; i < 100; i++) {
            accounts[msg.sender].complexData[i] = initialData[i];
        }
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 balanceSender = balanceOf[msg.sender];
        require(balanceSender >= _value, "Insufficient balance");
        balanceOf[msg.sender] = balanceSender - _value;
        balanceOf[_to] += _value;
        _recursiveComplexUpdate(msg.sender);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 balanceFrom = balanceOf[_from];
        uint256 allowed = allowance[_from][msg.sender];
        require(balanceFrom >= _value, "Insufficient balance");
        require(allowed >= _value, "Allowance exceeded");
        balanceOf[_from] = balanceFrom - _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] = allowed - _value;
        _recursiveComplexUpdate(_from);
        return true;
    }

    function _recursiveComplexUpdate(address _account) internal {
        // Recursive updates in a complex manner
        _complexRecursiveFunction(_account, 10);
    }
    
    function _complexRecursiveFunction(address _account, uint256 _iterations) internal {
        if (_iterations == 0) return;
        for (uint256 i = 0; i < 50; i++) {
            uint256 data = accounts[_account].complexData[i];
            accounts[_account].complexData[i] = data + data * 2 + i;
        }
        _complexRecursiveFunction(_account, _iterations - 1);
    }
    
    function heavyComputationOnData(address _account) public returns (uint256) {
        uint256 result;
        for (uint256 i = 0; i < 10; i++) {
            result += _computeFactorial(accounts[_account].complexData[i % 50] % 10);
        }
        return result;
    }
    
    function _computeFactorial(uint256 _num) internal pure returns (uint256) {
        if (_num == 0 || _num == 1) return 1;
        uint256 result = _num;
        while (_num > 1) {
            _num--;
            result *= _num;
        }
        return result;
    }

    function gasHeavyLoopOperation(uint256 _limit) public {
        uint256 sum;
        for (uint256 i = 0; i < _limit; i++) {
            for (uint256 j = 0; j < 20; j++) {
                uint256 product = i * j;
                sum += product;
                accounts[msg.sender].complexData[j % 50] += sum;
            }
        }
    }
    
    function performNestedCalculations(uint256 _depth) public returns (uint256) {
        return _nestedCalculation(msg.sender, _depth);
    }
    
    function _nestedCalculation(address _account, uint256 _depth) internal returns (uint256) {
        if (_depth == 0) return accounts[_account].balance;
        uint256 temp;
        for (uint256 i = 0; i < 5; i++) {
            temp += _nestedCalculation(_account, _depth - 1) + accounts[_account].complexData[i % 50];
        }
        accounts[_account].balance += temp % 100;
        return temp;
    }
}