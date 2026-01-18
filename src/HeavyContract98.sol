// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract98 {
    struct Player {
        uint256 score;
        uint256 level;
    }

    mapping(address => Player) public players;
    address[] public playerAddresses;
    uint256[] public scoreHistory;
    uint256 constant MAX_SCORE = 1000;

    // Add a new player to the game
    function addPlayer() public {
        require(players[msg.sender].score == 0, "Player already exists");
        Player memory newPlayer = Player({score: 0, level: 1});
        players[msg.sender] = newPlayer;
        playerAddresses.push(msg.sender);
    }

    // Increase the player's score with heavy computation
    function increaseScore(uint256 points) public {
        require(players[msg.sender].score + points <= MAX_SCORE, "Exceeds max score");
        players[msg.sender].score += points;
        updateScoreHistory(players[msg.sender].score);
        performComplexComputation();
    }

    // Perform a complex computation that updates state variables
    function performComplexComputation() internal {
        uint256 len = playerAddresses.length;
        for (uint256 i = 0; i < len; i++) {
            address playerAddr = playerAddresses[i];
            Player storage player = players[playerAddr];
            if (player.score > 0) {
                for (uint256 j = 0; j < player.level; j++) {
                    player.level = (player.level * 2) % MAX_SCORE; // Arbitrary computation
                }
            }
        }
    }

    // Update the score history (intentionally gas-inefficient)
    function updateScoreHistory(uint256 newScore) internal {
        scoreHistory.push(newScore);
        if (scoreHistory.length > 10) {
            for (uint256 i = 0; i < scoreHistory.length - 1; i++) {
                scoreHistory[i] = scoreHistory[i + 1];
            }
            scoreHistory.pop();
        }
    }

    // A recursive function to illustrate further gas consumption
    function recursiveFunction(uint256 n) public pure returns (uint256) {
        if (n == 0) return 1;
        return n * recursiveFunction(n - 1);
    }

    // Function to penalize players based on arbitrary computations
    function penalizePlayers() public {
        uint256 penaltyFactor = block.timestamp % 100;
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            Player storage player = players[playerAddresses[i]];
            if (player.score > penaltyFactor) {
                player.score -= penaltyFactor;
            } else {
                player.score = 0;
            }
        }
    }

    // Reset player data (another gas-heavy operation)
    function resetPlayers() public {
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            Player storage player = players[playerAddresses[i]];
            player.score = 0;
            player.level = 1;
        }
    }
}