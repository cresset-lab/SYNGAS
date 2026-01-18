// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract91Opt {
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(uint256 => Bid[]) public auctionBids;
    mapping(uint256 => address) public auctionWinners;
    uint256 public auctionCount;
    uint256 public bidIncrement;
    
    constructor(uint256 _bidIncrement) {
        bidIncrement = _bidIncrement;
        auctionCount = 0;
    }

    // Start a new auction
    function startAuction() public {
        auctionCount++;
    }

    // Place a bid on an auction
    function placeBid(uint256 auctionId) public payable {
        require(auctionId > 0 && auctionId <= auctionCount, "Invalid auction");
        require(msg.value > 0, "Zero bid not allowed");
        
        Bid memory newBid = Bid(msg.sender, msg.value, block.timestamp);
        auctionBids[auctionId].push(newBid);
        updateWinner(auctionId);
    }

    // Update the winner of the auction
    function updateWinner(uint256 auctionId) internal {
        uint256 highestBid = 0;
        address winner;
        Bid[] storage bids = auctionBids[auctionId];
        uint256 length = bids.length;
        for (uint256 i = 0; i < length; ) {
            uint256 bidAmount = bids[i].amount;
            if (bidAmount > highestBid) {
                highestBid = bidAmount;
                winner = bids[i].bidder;
            }
            unchecked { ++i; }
        }
        auctionWinners[auctionId] = winner;
    }

    // Recursive computation to simulate heavy processing (factorial calculation)
    function factorial(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        return n * factorial(n - 1);
    }

    // A complex function with nested loops and storage manipulation
    function complexOperation(uint256 auctionId) public {
        require(auctionId > 0 && auctionId <= auctionCount, "Invalid auction");
        uint256 totalBidAmount = 0;
        Bid[] storage bids = auctionBids[auctionId];
        uint256 length = bids.length;
        for (uint256 i = 0; i < length; ) {
            uint256 tempAmount = 0;
            for (uint256 j = i; j < length; ) {
                tempAmount += bids[j].amount;
                unchecked { ++j; }
            }
            totalBidAmount += tempAmount;
            unchecked { ++i; }
        }
        bidIncrement = totalBidAmount % auctionCount;
    }

    // Simulate a recursive storage update
    function recursiveStorageUpdate(uint256 count) public {
        if (count > 0) {
            auctionCount += count;
            recursiveStorageUpdate(count - 1);
        }
    }

    // Retrieve the highest bid for a given auction
    function getHighestBid(uint256 auctionId) public view returns (uint256) {
        require(auctionId > 0 && auctionId <= auctionCount, "Invalid auction");
        uint256 highestBid = 0;
        Bid[] storage bids = auctionBids[auctionId];
        uint256 length = bids.length;
        for (uint256 i = 0; i < length; ) {
            uint256 bidAmount = bids[i].amount;
            if (bidAmount > highestBid) {
                highestBid = bidAmount;
            }
            unchecked { ++i; }
        }
        return highestBid;
    }
}