
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract80Opt {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    mapping(address => Bid[]) public bids;
    mapping(address => uint256) public highestBid;
    address[] public participants;
    uint256 public totalBids;

    // Place a bid for the auction
    function placeBid() public payable {
        require(msg.value > 0, "Bid must be greater than zero");
        if (bids[msg.sender].length == 0) {
            participants.push(msg.sender);
        }
        bids[msg.sender].push(Bid(msg.sender, msg.value));
        totalBids++;
        updateHighestBid(msg.sender);
    }

    // Calculate the highest bid for a participant (gas intensive due to iteration)
    function updateHighestBid(address participant) internal {
        uint256 highest = 0;
        uint256 len = bids[participant].length;
        for (uint256 i = 0; i < len; i++) {
            uint256 amount = bids[participant][i].amount;
            if (amount > highest) {
                highest = amount;
            }
        }
        highestBid[participant] = highest;
    }

    // Recursive calculation to find the factorial of a number (gas intensive)
    function factorial(uint256 n) public pure returns (uint256 result) {
        require(n >= 0, "Negative numbers not allowed");
        result = 1;
        for (uint256 i = 2; i <= n; i++) {
            result *= i;
        }
    }

    // Heavy computation to sum all bids optimized
    function sumAllBids() public view returns (uint256) {
        uint256 total = 0;
        uint256 count = participants.length;
        for (uint256 i = 0; i < count; i++) {
            address participant = participants[i];
            uint256 len = bids[participant].length;
            for (uint256 j = 0; j < len; j++) {
                total += bids[participant][j].amount;
            }
        }
        return total;
    }

    // Emulate bidding wars with multiple nested loops and updates
    function biddingWar(uint256 rounds) public {
        require(participants.length > 0, "No participants");
        for (uint256 i = 0; i < rounds; i++) {
            uint256 len = participants.length;
            for (uint256 j = 0; j < len; j++) {
                uint256 randomIncrease = uint256(keccak256(abi.encodePacked(block.timestamp, i, j))) % 1000;
                address participant = participants[j];
                highestBid[participant] += randomIncrease;
                bids[participant].push(Bid(participant, randomIncrease));
                totalBids++;
            }
        }
    }

    // A function that calculates a complex series and updates state
    function complexSeries(uint256 x, uint256 terms) public {
        uint256 result = 0;
        for (uint256 i = 1; i <= terms; i++) {
            result += (power(x, i) / factorial(i));
        }
        highestBid[msg.sender] = result % (totalBids + 1);
    }

    // Helper function to calculate x to the power of n optimized
    function power(uint256 x, uint256 n) internal pure returns (uint256 result) {
        result = 1;
        uint256 base = x;
        while (n > 0) {
            if (n % 2 == 1) {
                result *= base;
            }
            base *= base;
            n /= 2;
        }
    }
}
