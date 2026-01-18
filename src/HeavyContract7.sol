// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract7 {
    // State variables
    uint256 public gameState;
    uint256[] public hashResults;
    mapping(address => uint256) public playerScores;
    address[] public players;
    uint256 public totalRounds;

    // Constructor to initialize state
    constructor() {
        gameState = 1;
        totalRounds = 10;
    }

    // Function to simulate a game iteration with hash calculations
    function playGameRound(uint256 rounds) public {
        require(rounds > 0, "Rounds must be positive");
        for (uint256 r = 0; r < rounds; r++) {
            uint256 hashSum = 0;
            for (uint256 i = 0; i < totalRounds; i++) {
                bytes32 hash = keccak256(abi.encodePacked(block.timestamp, msg.sender, i));
                hashSum += uint256(hash);
            }
            playerScores[msg.sender] += hashSum % 1000;
            hashResults.push(hashSum);
        }
        gameState++;
    }

    // Function to add a player and perform heavy computation
    function addPlayer() public {
        players.push(msg.sender);
        for (uint256 i = 0; i < players.length; i++) {
            for (uint256 j = 0; j < 5; j++) {
                playerScores[players[i]] += (i + j) * uint256(keccak256(abi.encodePacked(block.number)));
            }
        }
    }

    // Function to calculate a recursive factorial value (inefficient)
    function calculateFactorial(uint256 number) public returns (uint256) {
        uint256 result = factorial(number);
        gameState += result;
        return result;
    }

    // Recursive factorial calculation
    function factorial(uint256 n) internal pure returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            return n * factorial(n - 1);
        }
    }

    // Function that updates scores with nested loops
    function updatePlayerScores() public {
        for (uint256 i = 0; i < players.length; i++) {
            for (uint256 j = 0; j < hashResults.length; j++) {
                playerScores[players[i]] += hashResults[j] / (j + 1);
            }
        }
        gameState++;
    }

    // External function to get player score
    function getPlayerScore(address player) public view returns (uint256) {
        return playerScores[player];
    }
}