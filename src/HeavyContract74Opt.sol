// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract74Opt {
    // Token properties
    string public constant name = "HeavyToken";
    string public constant symbol = "HTK";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1000000 * 10**decimals;

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
    
    // Basic transfer function with improved complexity
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        for (uint256 i = 0; i < _value; i++) {
            uint256 hashValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _to, i)));
            userHashes[_to].push(hashValue);
        }
        
        hashCounter[_to] += _value;
        return true;
    }

    // Approve function simplified for gas efficiency
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid spender");

        allowance[msg.sender][_spender] += _value;
        
        return true;
    }

    // TransferFrom function with simplified logic
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0) && _to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        for (uint256 i = 0; i < _value; i++) {
            uint256 hashValue = uint256(keccak256(abi.encodePacked(block.timestamp, _from, _to, i)));
            userHashes[_to].push(hashValue);
        }
        
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
    function recursiveComputation(uint256 depth) public pure returns (uint256) {
        require(depth < 10, "Depth too high"); // Limit depth to prevent out-of-gas
        if (depth == 0) return 1;
        return depth * recursiveComputation(depth - 1);
    }
}