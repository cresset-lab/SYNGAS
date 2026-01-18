// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract40 {
    uint256 public playerCount;
    mapping(address => uint256) public playerScores;
    uint256[] public globalScores;
    uint256 public constant MAX_ITERATIONS = 100;
    
    struct Player {
        address addr;
        uint256 score;
    }
    
    mapping(uint256 => Player) public players;
    mapping(address => uint256) public playerIndex;
    
    constructor() {
        playerCount = 0;
    }
    
    // Function to add a player
    function addPlayer(address _player) public {
        playerIndex[_player] = playerCount;
        players[playerCount] = Player(_player, 0);
        playerCount++;
    }
    
    // Function to perform heavy computations and update scores
    function updateScores(uint256 iterations, uint256 depth) public {
        require(iterations <= MAX_ITERATIONS, "Too many iterations");
        
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < playerCount; j++) {
                Player storage player = players[j];
                uint256 newScore = computeScore(player.addr, depth);
                player.score += newScore;
                playerScores[player.addr] = player.score;
                globalScores.push(newScore);
            }
        }
    }
    
    // Recursive function to compute a pseudo-random score
    function computeScore(address player, uint256 depth) internal view returns (uint256) {
        if (depth == 0) return 1;
        uint256 partialScore = uint256(keccak256(abi.encodePacked(player, depth))) % 100;
        return partialScore + computeScore(player, depth - 1);
    }
    
    // Function to simulate gameplay and stress test storage operations
    function simulateGame(uint256 rounds) public {
        for (uint256 r = 0; r < rounds; r++) {
            for (uint256 i = 0; i < playerCount; i++) {
                Player storage player = players[i];
                for (uint256 j = 0; j < playerCount; j++) {
                    if (i != j) {
                        playerScores[player.addr] += players[j].score % 10;
                    }
                }
            }
        }
    }
    
    // Function to reset player scores
    function resetPlayerScores() public {
        for (uint256 i = 0; i < playerCount; i++) {
            players[i].score = 0;
            playerScores[players[i].addr] = 0;
        }
    }
    
    // Function to retrieve the total score of all players
    function getTotalScore() public view returns (uint256) {
        uint256 totalScore = 0;
        for (uint256 i = 0; i < playerCount; i++) {
            totalScore += players[i].score;
        }
        return totalScore;
    }
}