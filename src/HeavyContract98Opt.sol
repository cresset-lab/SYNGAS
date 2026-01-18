
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract98Opt {
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
        players[msg.sender] = Player(0, 1);
        playerAddresses.push(msg.sender);
    }

    // Increase the player's score with heavy computation
    function increaseScore(uint256 points) public {
        Player storage player = players[msg.sender];
        require(player.score + points <= MAX_SCORE, "Exceeds max score");
        player.score += points;
        updateScoreHistory(player.score);
        performComplexComputation();
    }

    // Perform a complex computation that updates state variables
    function performComplexComputation() internal {
        uint256 len = playerAddresses.length;
        for (uint256 i = 0; i < len; ) {
            address playerAddr = playerAddresses[i];
            Player storage player = players[playerAddr];
            if (player.score > 0) {
                uint256 level = player.level;
                for (uint256 j = 0; j < level; ) {
                    level = (level * 2) % MAX_SCORE; // Arbitrary computation
                    unchecked { j++; }
                }
                player.level = level;
            }
            unchecked { i++; }
        }
    }

    // Update the score history (improved)
    function updateScoreHistory(uint256 newScore) internal {
        if (scoreHistory.length == 10) {
            for (uint256 i = 0; i < 9; ) {
                scoreHistory[i] = scoreHistory[i + 1];
                unchecked { i++; }
            }
            scoreHistory[9] = newScore;
        } else {
            scoreHistory.push(newScore);
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
        uint256 len = playerAddresses.length;
        for (uint256 i = 0; i < len; ) {
            Player storage player = players[playerAddresses[i]];
            if (player.score > penaltyFactor) {
                player.score -= penaltyFactor;
            } else {
                player.score = 0;
            }
            unchecked { i++; }
        }
    }

    // Reset player data (another gas-heavy operation)
    function resetPlayers() public {
        uint256 len = playerAddresses.length;
        for (uint256 i = 0; i < len; ) {
            Player storage player = players[playerAddresses[i]];
            player.score = 0;
            player.level = 1;
            unchecked { i++; }
        }
    }
}
