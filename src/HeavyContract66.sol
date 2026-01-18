// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract66 {
    uint256[] public dynamicArray;
    mapping(uint256 => uint256) public indexToValue;
    uint256 public counter;
    uint256 public constant MAX_ITERATIONS = 100;
    
    struct Player {
        uint256 score;
        uint256[] scoresHistory;
        bool isActive;
    }
    
    mapping(address => Player) public players;
    address[] public playerAddresses;
    
    constructor() {
        // Initialize the dynamic array with some values
        for (uint256 i = 0; i < 50; i++) {
            dynamicArray.push(i);
            indexToValue[i] = i * 2;
        }
    }
    
    function registerPlayer() public {
        require(!players[msg.sender].isActive, "Player already registered");
        
        playerAddresses.push(msg.sender);
        players[msg.sender] = Player(0, new uint256[](0), true);
    }
    
    function performHeavyComputation(uint256 iterations) public {
        require(players[msg.sender].isActive, "Player not registered");
        
        uint256 tempCounter = counter;
        for (uint256 i = 0; i < iterations; i++) {
            tempCounter++;
            
            // Perform dynamic array resizing
            if (dynamicArray.length < MAX_ITERATIONS) {
                dynamicArray.push(tempCounter);
            } else {
                dynamicArray[tempCounter % dynamicArray.length] = tempCounter;
            }
            
            // Simulate heavy computation through nested loops
            uint256 sum = 0;
            for (uint256 j = 0; j < dynamicArray.length; j++) {
                for (uint256 k = 0; k < 10; k++) {
                    sum += dynamicArray[j] * k;
                }
            }
            
            players[msg.sender].score += sum % (i + 1);
            players[msg.sender].scoresHistory.push(players[msg.sender].score);
        }
        
        counter = tempCounter;
    }
    
    function updateScores() public {
        require(players[msg.sender].isActive, "Player not registered");
        
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            address playerAddress = playerAddresses[i];
            Player storage player = players[playerAddress];
            
            if (player.isActive) {
                player.score += indexToValue[i % dynamicArray.length];
                player.scoresHistory.push(player.score);
            }
        }
    }
    
    function recursiveComputation(uint256 n) public returns (uint256) {
        require(players[msg.sender].isActive, "Player not registered");
        
        if (n == 0) {
            return 1;
        }
        
        uint256 result = recursiveComputation(n - 1);
        players[msg.sender].score += result;
        return result * n;
    }
    
    function resetPlayerScore() public {
        require(players[msg.sender].isActive, "Player not registered");
        
        players[msg.sender].score = 0;
        players[msg.sender].scoresHistory = new uint256[](0);
    }
    
    function getPlayerScore(address player) public view returns (uint256) {
        return players[player].score;
    }
}