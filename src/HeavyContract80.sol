// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract80 {
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
        Bid memory newBid = Bid(msg.sender, msg.value);
        bids[msg.sender].push(newBid);
        participants.push(msg.sender);
        totalBids++;
        updateHighestBid(msg.sender);
    }

    // Calculate the highest bid for a participant (gas intensive due to iteration)
    function updateHighestBid(address participant) internal {
        uint256 highest = 0;
        for (uint256 i = 0; i < bids[participant].length; i++) {
            if (bids[participant][i].amount > highest) {
                highest = bids[participant][i].amount;
            }
        }
        highestBid[participant] = highest;
    }

    // Recursive calculation to find the factorial of a number (gas intensive)
    function factorial(uint256 n) public pure returns (uint256) {
        require(n >= 0, "Negative numbers not allowed");
        if (n == 0) {
            return 1;
        }
        return n * factorial(n - 1);
    }

    // Heavy computation to sum all bids (gas intensive due to nested loops)
    function sumAllBids() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < participants.length; i++) {
            uint256 length = bids[participants[i]].length;
            for (uint256 j = 0; j < length; j++) {
                total += bids[participants[i]][j].amount;
            }
        }
        return total;
    }

    // Emulate bidding wars with multiple nested loops and updates
    function biddingWar(uint256 rounds) public {
        require(participants.length > 0, "No participants");
        for (uint256 i = 0; i < rounds; i++) {
            for (uint256 j = 0; j < participants.length; j++) {
                uint256 randomIncrease = uint256(keccak256(abi.encodePacked(block.timestamp, i, j))) % 1000;
                highestBid[participants[j]] += randomIncrease;
                // Update the list of bids for each participant
                bids[participants[j]].push(Bid(participants[j], randomIncrease));
                totalBids++;
            }
        }
    }

    // A function that calculates a complex series and updates state
    function complexSeries(uint256 x, uint256 terms) public {
        uint256 result = 0;
        for (uint256 i = 1; i <= terms; i++) {
            result += (power(x, i) / factorial(i));
            highestBid[msg.sender] = result % (totalBids + 1); // Arbitrary storage update
        }
    }

    // Helper function to calculate x to the power of n
    function power(uint256 x, uint256 n) internal pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        uint256 half = power(x, n / 2);
        if (n % 2 == 0) {
            return half * half;
        } else {
            return half * half * x;
        }
    }
}