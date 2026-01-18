// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract7Opt {
    // State variables
    uint256 public gameState = 1;
    uint256[] private hashResults;
    mapping(address => uint256) private playerScores;
    address[] private players;
    uint256 public totalRounds = 10;

    // Function to simulate a game iteration with hash calculations
    function playGameRound(uint256 rounds) public {
        require(rounds > 0, "Rounds must be positive");
        for (uint256 r = 0; r < rounds; r++) {
            uint256 hashSum = 0;
            for (uint256 i = 0; i < totalRounds; i++) {
                hashSum += uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i)));
            }
            playerScores[msg.sender] += hashSum % 1000;
            hashResults.push(hashSum);
        }
        gameState++;
    }

    // Function to add a player and perform heavy computation
    function addPlayer() public {
        uint256 playersLen = players.length;
        players.push(msg.sender);
        uint256 blockHash = uint256(keccak256(abi.encodePacked(block.number)));
        for (uint256 i = 0; i < playersLen; i++) {
            uint256 playerScore = playerScores[players[i]];
            for (uint256 j = 0; j < 5; j++) {
                playerScore += (i + j) * blockHash;
            }
            playerScores[players[i]] = playerScore;
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
        uint256 playersLen = players.length;
        uint256 hashResultsLen = hashResults.length;
        for (uint256 i = 0; i < playersLen; i++) {
            uint256 playerScore = playerScores[players[i]];
            for (uint256 j = 0; j < hashResultsLen; j++) {
                playerScore += hashResults[j] / (j + 1);
            }
            playerScores[players[i]] = playerScore;
        }
        gameState++;
    }

    // External function to get player score
    function getPlayerScore(address player) public view returns (uint256) {
        return playerScores[player];
    }
}