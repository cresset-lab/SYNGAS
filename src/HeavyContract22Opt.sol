// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract22Opt {
    string public constant name = "HeavyToken";
    string public constant symbol = "HVT";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1000000 * 10 ** uint256(decimals);
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public computationCounter;
    uint256 public heavyComputationResult;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        uint256 localComputationResult = heavyComputationResult;
        uint256 localComputationCounter = computationCounter;

        for (uint256 i = 0; i < 100; i++) {
            localComputationCounter++;
            localComputationResult = uint256(keccak256(abi.encodePacked(localComputationResult, localComputationCounter, block.timestamp)));
        }

        computationCounter = localComputationCounter;
        heavyComputationResult = localComputationResult;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        
        uint256 localComputationResult = heavyComputationResult;
        uint256 localComputationCounter = computationCounter;

        for (uint256 i = 0; i < 50; i++) {
            localComputationCounter++;
            localComputationResult = uint256(keccak256(abi.encodePacked(localComputationResult, localComputationCounter, block.timestamp)));
        }

        computationCounter = localComputationCounter;
        heavyComputationResult = localComputationResult;

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        uint256 localComputationResult = heavyComputationResult;
        uint256 localComputationCounter = computationCounter;

        for (uint256 i = 0; i < 50; i++) {
            for (uint256 j = 0; j < 10; j++) {
                localComputationCounter++;
                localComputationResult = uint256(keccak256(abi.encodePacked(localComputationResult, localComputationCounter, block.timestamp)));
            }
        }

        computationCounter = localComputationCounter;
        heavyComputationResult = localComputationResult;

        return true;
    }

    function computeHeavyHash(uint256 _input, uint256 _iterations) public returns (uint256) {
        uint256 localComputation = _input;
        for (uint256 i = 0; i < _iterations; i++) {
            for (uint256 j = 0; j < 10; j++) {
                localComputation = uint256(keccak256(abi.encodePacked(localComputation, block.timestamp)));
            }
        }
        heavyComputationResult = localComputation;
        return localComputation;
    }

    function recursiveComputation(uint256 _depth) public returns (uint256) {
        if (_depth == 0) {
            return heavyComputationResult;
        }
        heavyComputationResult = uint256(keccak256(abi.encodePacked(recursiveComputation(_depth - 1), block.timestamp)));
        return heavyComputationResult;
    }
}