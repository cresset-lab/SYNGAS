// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract60 {
    // State variables
    struct Bid {
        address bidder;
        uint256 amount;
    }
    
    mapping(address => Bid[]) public bids;
    mapping(address => uint256) public highestBids;
    mapping(address => uint256) public totalBids;
    address[] public bidders;

    uint256 public totalAuctions;

    // Place a bid
    function placeBid(uint256 auctionId, uint256 bidAmount) public {
        // Gas-intensive operations
        require(bidAmount > 0, "Bid amount must be greater than zero");
        
        // Check if the bidder already exists
        bool bidderExists = false;
        for (uint256 i = 0; i < bidders.length; i++) {
            if (bidders[i] == msg.sender) {
                bidderExists = true;
                break;
            }
        }
        
        if (!bidderExists) {
            bidders.push(msg.sender);
        }

        Bid memory newBid = Bid({bidder: msg.sender, amount: bidAmount});
        bids[msg.sender].push(newBid);
        totalBids[msg.sender] += bidAmount;

        // Update the highest bid for the auction
        if (bidAmount > highestBids[msg.sender]) {
            highestBids[msg.sender] = bidAmount;
        }

        // Increase total auctions (intended as a gas-heavy operation)
        for (uint256 i = 0; i < 100; i++) {
            totalAuctions++;
        }
    }

    // Calculate sum of all bids for a specific user
    function calculateTotalBids(address user) public view returns (uint256) {
        uint256 sum = 0;
        Bid[] memory userBids = bids[user];
        for (uint256 i = 0; i < userBids.length; i++) {
            sum += userBids[i].amount;
        }
        return sum;
    }

    // Fetch highest bid for a specific user
    function getHighestBid(address user) public view returns (uint256) {
        return highestBids[user];
    }

    // Complex computation function
    function heavyComputation(uint256 input) public pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 1; i <= input; i++) {
            for (uint256 j = 1; j <= i; j++) {
                result = (result * j) % (input + 1);
            }
        }
        return result;
    }

    // Recursive function example for gas testing
    function factorial(uint256 n) public pure returns (uint256) {
        if (n == 0) return 1;
        return n * factorial(n - 1);
    }
}