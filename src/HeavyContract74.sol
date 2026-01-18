// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract74 {
    // Token properties
    string public name = "HeavyToken";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals));

    // State variables for balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Complex state variables for gas-intense operations
    mapping(address => uint256) public hashCounter;
    mapping(address => uint256[]) public userHashes;
    
    // Constructor to set initial supply and assign to creator
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }
    
    // Basic transfer function with added complexity
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        for (uint256 i = 0; i < _value; i++) {
            // Calculate a hash for each token transferred (intentionally inefficient)
            uint256 hashValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _to, i)));
            balanceOf[msg.sender]--;
            balanceOf[_to]++;
            // Store hash values in user's hash array
            userHashes[_to].push(hashValue);
            hashCounter[_to]++;
        }

        return true;
    }

    // Approve function with unnecessary complexity
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid spender");

        // Perform a redundant operation to increase gas usage
        for (uint256 i = 0; i < 5; i++) {
            allowance[msg.sender][_spender] += _value / 5;
        }
        
        return true;
    }

    // TransferFrom function with complex logic
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0) && _to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        uint256 iterations = _value * 10;
        for (uint256 i = 0; i < iterations; i++) {
            // Perform excessive hash computations
            uint256 hashValue = uint256(keccak256(abi.encodePacked(block.timestamp, _from, _to, i)));
            if (i % 10 == 0) {
                userHashes[_to].push(hashValue);
            }
        }
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        return true;
    }

    // A function to compute a large number of hashes
    function computeHashes(uint256 iterations) public {
        require(iterations > 0, "Iterations must be greater than zero");

        for (uint256 i = 0; i < iterations; i++) {
            uint256 hashValue = uint256(keccak256(abi.encodePacked(block.difficulty, msg.sender, i)));
            userHashes[msg.sender].push(hashValue);
        }
    }

    // Simulate a complex recursive function
    function recursiveComputation(uint256 depth) public returns (uint256) {
        require(depth < 10, "Depth too high"); // Limit depth to prevent out-of-gas
        if (depth == 0) return 1;
        return depth * recursiveComputation(depth - 1);
    }
}