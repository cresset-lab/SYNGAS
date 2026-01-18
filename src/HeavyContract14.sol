// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract14 {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    mapping(address => uint256) public pendingReturns;
    mapping(uint256 => Bid[]) public bids;
    mapping(uint256 => address) public highestBidder;
    mapping(uint256 => uint256) public highestBid;
    uint256 public auctionCount;

    event BidPlaced(uint256 auctionId, address bidder, uint256 amount);

    constructor() {
        auctionCount = 0;
    }

    // Start a new auction
    function startAuction() public {
        auctionCount++;
    }

    // Place a bid on a specific auction
    function placeBid(uint256 auctionId) public payable {
        require(auctionId > 0 && auctionId <= auctionCount, "Invalid auction ID");
        require(msg.value > 0, "Bid must be greater than zero");

        // Add bid to the auction
        bids[auctionId].push(Bid(msg.sender, msg.value));
        pendingReturns[msg.sender] += msg.value;

        // Update the highest bid if necessary
        if (msg.value > highestBid[auctionId]) {
            highestBidder[auctionId] = msg.sender;
            highestBid[auctionId] = msg.value;
        }

        emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    // Simple heavy computation: Iterate over all bids
    function calculateTotalBidsValue(uint256 auctionId) public view returns (uint256) {
        uint256 totalValue = 0;
        Bid[] storage auctionBids = bids[auctionId];

        for (uint256 i = 0; i < auctionBids.length; i++) {
            totalValue += auctionBids[i].amount;
        }
        return totalValue;
    }

    // Heavy computation with complex calculations
    function findSumOfSquaredBids(uint256 auctionId) public view returns (uint256) {
        uint256 sumOfSquares = 0;
        Bid[] storage auctionBids = bids[auctionId];

        for (uint256 i = 0; i < auctionBids.length; i++) {
            uint256 bidAmount = auctionBids[i].amount;
            sumOfSquares += bidAmount * bidAmount;
        }
        return sumOfSquares;
    }

    // Nested loops with mapping operations
    function getAddressBidCounts() public returns (uint256[] memory) {
        uint256[] memory bidCounts = new uint256[](auctionCount);

        for (uint256 auctionId = 1; auctionId <= auctionCount; auctionId++) {
            Bid[] storage auctionBids = bids[auctionId];
            for (uint256 i = 0; i < auctionBids.length; i++) {
                address bidder = auctionBids[i].bidder;
                pendingReturns[bidder]--; // Artificial decrement for gas consumption
            }
            bidCounts[auctionId - 1] = auctionBids.length;
        }
        return bidCounts;
    }

    // Recursive function for demonstration (not recommended in practice)
    function recursiveBidSum(uint256 auctionId, uint256 index) public view returns (uint256) {
        if (index == 0) return bids[auctionId][index].amount;
        return bids[auctionId][index].amount + recursiveBidSum(auctionId, index - 1);
    }

    // Function to withdraw pending returns
    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No pending returns");

        pendingReturns[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}