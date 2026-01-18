// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract67 {
    struct Bid {
        uint256 amount;
        address bidder;
    }

    mapping(uint256 => Bid[]) public auctions;
    mapping(address => uint256) public userBids;
    uint256 public totalBids;
    uint256 public auctionCount;

    event NewBid(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionFinalized(uint256 indexed auctionId, address indexed winner, uint256 amount);

    constructor() {
        auctionCount = 0;
        totalBids = 0;
    }

    function createAuction() public returns (uint256) {
        return auctionCount++;
    }

    function placeBid(uint256 auctionId, uint256 amount) public {
        require(auctionId < auctionCount, "Auction does not exist");
        auctions[auctionId].push(Bid(amount, msg.sender));
        userBids[msg.sender] += amount;
        totalBids++;

        emit NewBid(auctionId, msg.sender, amount);

        // Intensely update state variables in a loop
        for (uint256 i = 0; i < 100; i++) {
            userBids[msg.sender] += 1;
        }
    }

    function finalizeAuction(uint256 auctionId) public {
        require(auctionId < auctionCount, "Auction does not exist");
        Bid[] storage bids = auctions[auctionId];
        uint256 maxBid = 0;
        address winner;

        // Nested loop to intentionally create gas-heavy operations
        for (uint256 i = 0; i < bids.length; i++) {
            for (uint256 j = i+1; j < bids.length; j++) {
                if (bids[j].amount > bids[i].amount) {
                    Bid memory temp = bids[i];
                    bids[i] = bids[j];
                    bids[j] = temp;
                }
            }

            if (bids[i].amount > maxBid) {
                maxBid = bids[i].amount;
                winner = bids[i].bidder;
            }
        }

        emit AuctionFinalized(auctionId, winner, maxBid);

        // Update user bids with lots of storage operations
        for (uint256 k = 0; k < bids.length; k++) {
            userBids[bids[k].bidder] = 0;
        }
    }

    function computeHeavyCalculation(uint256 start, uint256 end) public pure returns (uint256) {
        uint256 sum = 0;
        // Compute intensive loop
        for (uint256 i = start; i < end; i++) {
            for (uint256 j = start; j < end; j++) {
                sum += i * j;
            }
        }
        return sum;
    }

    function repeatedStorageUpdate(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            userBids[msg.sender] = i;
        }
    }

    function bidCount(uint256 auctionId) public view returns (uint256) {
        require(auctionId < auctionCount, "Auction does not exist");
        return auctions[auctionId].length;
    }
}