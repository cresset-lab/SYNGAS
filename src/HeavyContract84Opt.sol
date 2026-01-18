// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract84Opt {
    // State variables
    uint256[] public gameBoard;
    mapping(address => uint256) public playerScores;
    uint256 public constant MATRIX_SIZE = 100;
    uint256 private constant MAX_SCORE = 1000;

    constructor() {
        // Initialize a game board with size MATRIX_SIZE
        gameBoard = new uint256[](MATRIX_SIZE);
    }

    // Function to simulate a game move which modifies the game board heavily
    function makeMove(uint256 index, uint256 value) public {
        require(index < MATRIX_SIZE, "Index out of bounds");
        // Heavy computation: updating adjacent cells
        for (uint256 i = index; i < MATRIX_SIZE; i++) {
            gameBoard[i] += value;
        }
        updatePlayerScore(msg.sender, value);
    }

    // Internal function to update player score based on moves
    function updatePlayerScore(address player, uint256 increment) internal {
        uint256 newScore = playerScores[player] + increment;
        playerScores[player] = newScore;

        // Simulate complex calculation
        if (newScore > MAX_SCORE) {
            uint256 modValue = MAX_SCORE; // Store MAX_SCORE in a local variable
            for (uint256 i = 0; i < MATRIX_SIZE; i++) {
                uint256 current = gameBoard[i];
                if (current > 0) {
                    gameBoard[i] = current % modValue;
                }
            }
        }
    }

    // Calculate the total score of the game board
    function calculateTotalScore() public view returns (uint256) {
        uint256 totalScore = 0;
        for (uint256 i = 0; i < MATRIX_SIZE; i++) {
            totalScore += gameBoard[i];
        }
        return totalScore;
    }

    // Recursive function to simulate a complex game scenario
    function recursiveCompute(uint256 n) public pure returns (uint256) {
        if (n == 0) return 0;
        return n * (n + 1) / 2;  // Use formula to calculate sum instead of recursion
    }

    // Function to reset the board with a heavy computation pattern
    function resetBoard() public {
        for (uint256 i = 0; i < MATRIX_SIZE; i++) {
            gameBoard[i] = 0;
        }
        // Nested loop to simulate heavy operations
        uint256 sum = 0;
        for (uint256 i = 0; i < MATRIX_SIZE; i++) {
            // An optimization to reduce unnecessary loops by reducing loop range
            // Updated logic to avoid the nested loop if i == 0
            sum += i * (i - 1) / 2; 
        }
    }
    
    // Update a range of the game board heavily
    function updateRange(uint256 start, uint256 end, uint256 value) public {
        require(start < end && end <= MATRIX_SIZE, "Invalid range");
        for (uint256 i = start; i < end; i++) {
            gameBoard[i] = value;
        }
    }
}