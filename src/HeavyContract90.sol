// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract90 {

    // State variables
    mapping(address => uint256) public userScores;
    uint256 public totalRounds;
    uint256[] public gameHistory;
    address[] public players;

    // Constants
    uint256 constant ROUNDS = 100;
    uint256 constant HASH_ITERATIONS = 1000;

    // Function to participate in the game
    function participate() public {
        // Add to players list
        players.push(msg.sender);
    }

    // Function that simulates a game round
    function playRound() public {
        require(players.length > 0, "No players have registered.");

        uint256 score = 0;
        for (uint256 i = 0; i < ROUNDS; i++) {
            score += computeHash(i);
        }

        userScores[msg.sender] += score;
        totalRounds++;
        gameHistory.push(score);
    }

    // Heavy computational function: computes a hash in iterations
    function computeHash(uint256 seed) internal pure returns (uint256) {
        bytes32 hash = keccak256(abi.encodePacked(seed));
        for (uint256 i = 0; i < HASH_ITERATIONS; i++) {
            hash = keccak256(abi.encodePacked(hash, i));
        }
        return uint256(hash);
    }

    // Function to reset the game (for testing purposes)
    function resetGame() public {
        for (uint256 i = 0; i < players.length; i++) {
            userScores[players[i]] = 0;
        }
        delete players;
        totalRounds = 0;
        delete gameHistory;
    }

    // Function to get the historical average score
    function getHistoricalAverageScore() public view returns (uint256) {
        require(totalRounds > 0, "No rounds played yet.");

        uint256 sum = 0;
        for (uint256 i = 0; i < gameHistory.length; i++) {
            sum += gameHistory[i];
        }
        return sum / totalRounds;
    }

    // External function to simulate multiple rounds
    function playMultipleRounds(uint256 numRounds) public {
        require(players.length > 0, "No players have registered.");
        uint256 score = 0;
        for (uint256 i = 0; i < numRounds; i++) {
            for (uint256 j = 0; j < ROUNDS; j++) {
                score += computeHash(j);
            }
        }
        userScores[msg.sender] += score;
        totalRounds += numRounds;
        for (uint256 i = 0; i < numRounds; i++) {
            gameHistory.push(score / numRounds);
        }
    }
}