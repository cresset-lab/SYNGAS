// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract66Opt {
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
        uint256 dynamicArrayLength = 50;
        dynamicArray = new uint256[](dynamicArrayLength);
        for (uint256 i = 0; i < dynamicArrayLength; i++) {
            dynamicArray[i] = i;
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
        uint256 dynamicLen = dynamicArray.length;  // Cache array length

        for (uint256 i = 0; i < iterations; i++) {
            tempCounter++;
            
            if (dynamicLen < MAX_ITERATIONS) {
                dynamicArray.push(tempCounter);
                dynamicLen++;  // Update cached length
            } else {
                dynamicArray[tempCounter % dynamicLen] = tempCounter;
            }
            
            uint256 sum = 0;
            for (uint256 j = 0; j < dynamicLen; j++) {
                uint256 value = dynamicArray[j];
                for (uint256 k = 0; k < 10; k++) {
                    sum += value * k;
                }
            }
            
            uint256 score = players[msg.sender].score + (sum % (i + 1));
            players[msg.sender].score = score;
            players[msg.sender].scoresHistory.push(score);
        }
        
        counter = tempCounter;
    }
    
    function updateScores() public {
        require(players[msg.sender].isActive, "Player not registered");

        uint256 indexLen = dynamicArray.length;  // Cache array length

        for (uint256 i = 0; i < playerAddresses.length; i++) {
            address playerAddress = playerAddresses[i];
            Player storage player = players[playerAddress];
            
            if (player.isActive) {
                uint256 scoreIncrease = indexToValue[i % indexLen];
                player.score += scoreIncrease;
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
        
        Player storage player = players[msg.sender];
        player.score = 0;
        delete player.scoresHistory;
    }
    
    function getPlayerScore(address player) public view returns (uint256) {
        return players[player].score;
    }
}