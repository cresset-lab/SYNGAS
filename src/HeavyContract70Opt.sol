// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract70Opt {
    struct Player {
        uint256 score;
        uint256 level;
    }

    mapping(address => Player) public players;
    uint256[] public leaderboard;

    // Recursive Fibonacci calculation stored in mapping
    mapping(uint256 => uint256) public fibResults;
    uint256 public fibCallCount;

    // Game state variables
    uint256 public gameCycle;
    uint256 public constant MAX_LEVEL = 100;

    // Constructor to initialize the game
    constructor() {
        gameCycle = 1;
        fibCallCount = 0;
    }

    // Heavy computation: Recursive Fibonacci calculation
    function recursiveFibonacci(uint256 n) public returns (uint256) {
        fibCallCount++;
        if (n <= 1) return n;
        uint256 result = fibResults[n];
        if (result != 0) return result;
        result = recursiveFibonacci(n - 1) + recursiveFibonacci(n - 2);
        fibResults[n] = result;
        return result;
    }

    // Heavy computation: Update player score with nested loops and storage writes
    function updatePlayerScore(address player, uint256 scoreIncrement) public {
        Player storage p = players[player];
        p.score += scoreIncrement;
        uint256 initialLevel = p.level;

        // Simulate a heavy operation
        unchecked {
            for (uint256 i = 0; i < 10; i++) {
                for (uint256 j = 0; j < 10; j++) {
                    p.level = (initialLevel + i + j) % MAX_LEVEL;
                }
            }
        }
    }

    // External function to simulate a game cycle with storage updates
    function advanceGameCycle() public {
        uint256 newGameCycle = gameCycle + 1;
        gameCycle = newGameCycle;
        uint256 adjustment = newGameCycle % 10;

        uint256 lbLength = leaderboard.length;
        for (uint256 i = 0; i < lbLength; i++) {
            players[address(uint160(uint256(keccak256(abi.encodePacked(i)))))]
                .score += adjustment;
        }
    }

    // Function to calculate scores based on Fibonacci sequence
    function calculateFibonacciScores(uint256[] calldata playerIndexes) public {
        uint256 pLength = playerIndexes.length;
        for (uint256 i = 0; i < pLength; i++) {
            uint256 idx = playerIndexes[i];
            address playerAddress = address(uint160(uint256(keccak256(abi.encodePacked(idx)))));
            uint256 fibScore = recursiveFibonacci(players[playerAddress].score % 20);
            players[playerAddress].score += fibScore;
        }
    }

    // Function to add a player to the leaderboard
    function addPlayerToLeaderboard(address player) public {
        leaderboard.push(uint256(uint160(player)));
    }

    // Function to run a heavy operation over the leaderboard
    function runLeaderboardComputation() public {
        uint256 lbLength = leaderboard.length;
        for (uint256 i = 0; i < lbLength; i++) {
            address playerAddress = address(uint160(leaderboard[i]));
            updatePlayerScore(playerAddress, recursiveFibonacci(players[playerAddress].level % 10));
        }
    }
}