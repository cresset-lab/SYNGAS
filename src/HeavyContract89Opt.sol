// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract89Opt {
    string public constant name = "Heavy Token";
    string public constant symbol = "HTK";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1_000_000 * (10 ** uint256(decimals));

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        _complexTransferLogic(msg.sender, _to, _value);
        return true;
    }

    function _complexTransferLogic(address _from, address _to, uint256 _value) internal {
        uint256 tempValue = _value;
        uint256 result = 1;
        for (uint256 i = 1; i <= 10; i++) {
            result *= tempValue;
        }
        tempValue = result;

        balanceOf[_from] -= tempValue;
        balanceOf[_to] += tempValue;
    }

    function _recursiveCalculation(uint256 num) internal pure returns (uint256) {
        return num == 0 ? 1 : num * _recursiveCalculation(num - 1);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        _complexTransferLogic(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function performHeavyComputation(uint256[] calldata data) public returns (uint256) {
        uint256 result = 0;
        uint256 dataLen = data.length;
        for (uint256 i = 0; i < dataLen; i++) {
            result += _intensiveComputation(data[i]);
        }
        return result;
    }

    function _intensiveComputation(uint256 value) internal view returns (uint256) {
        uint256 sum = 0;
        uint256 balanceMod = balanceOf[msg.sender] % 10;
        for (uint256 i = 0; i < value % 10; i++) {
            for (uint256 j = 0; j < balanceMod; j++) {
                sum += i * j;
            }
        }
        return sum;
    }

    function updateBalances(uint256 numberOfUpdates) public {
        uint256 balance = balanceOf[msg.sender];
        for (uint256 i = 0; i < numberOfUpdates; i++) {
            balance = (balance + 1) % totalSupply;
        }
        balanceOf[msg.sender] = balance;
    }

    function nestedLoopsComputation(uint256 times) public returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < times; i++) {
            for (uint256 j = i; j < times; j++) {
                for (uint256 k = j; k < times; k++) {
                    total += k % (i + 1);
                }
            }
        }
        return total;
    }
}