// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract22 {
    // Basic token details
    string public name = "HeavyToken";
    string public symbol = "HVT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals));
    
    // Mapping from account addresses to their balances
    mapping(address => uint256) public balanceOf;
    
    // Approved allowances
    mapping(address => mapping(address => uint256)) public allowance;

    // Frequent update variables
    uint256 public computationCounter;
    uint256 public heavyComputationResult;

    // Constructor to initialize the supply to the contract creator
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    // Complex transfer function
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        // Heavy computation: hash calculation in iterations
        for (uint256 i = 0; i < 100; i++) {
            computationCounter++;
            heavyComputationResult = uint256(keccak256(abi.encodePacked(heavyComputationResult, computationCounter, block.timestamp)));
        }

        // Redundant storage updates to make it gas expensive
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        return true;
    }

    // A complex approval function
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        
        // Additional heavy computation
        for (uint256 i = 0; i < 50; i++) {
            computationCounter++;
            heavyComputationResult = uint256(keccak256(abi.encodePacked(heavyComputationResult, computationCounter, block.timestamp)));
        }

        return true;
    }

    // Spend approved tokens
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        // Heavy computation in nested loops
        for (uint256 i = 0; i < 50; i++) {
            for (uint256 j = 0; j < 10; j++) {
                computationCounter++;
                heavyComputationResult = uint256(keccak256(abi.encodePacked(heavyComputationResult, computationCounter, block.timestamp)));
            }
        }

        return true;
    }

    // Compute a heavy hash based on input parameters
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

    // Recursive function to simulate heavy operations
    function recursiveComputation(uint256 _depth) public returns (uint256) {
        if (_depth == 0) {
            return heavyComputationResult;
        }
        heavyComputationResult = uint256(keccak256(abi.encodePacked(recursiveComputation(_depth - 1), block.timestamp)));
        return heavyComputationResult;
    }
}