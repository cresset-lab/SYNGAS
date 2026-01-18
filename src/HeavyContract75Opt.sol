
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract75Opt {
    struct Bid {
        uint256 amount;
        address bidder;
    }

    mapping(uint256 => Bid[]) public auctionBids;
    mapping(uint256 => address) public auctionWinners;
    mapping(uint256 => uint256) public auctionEndTimes;
    mapping(address => uint256) public pendingReturns;

    uint256 public auctionCount;
    uint256 public constant AUCTION_DURATION = 7 days;

    event NewBid(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 indexed auctionId, address winner, uint256 amount);

    constructor() {
        auctionCount = 0;
    }

    function startNewAuction() public {
        auctionEndTimes[++auctionCount] = block.timestamp + AUCTION_DURATION;
    }

    function placeBid(uint256 auctionId) public payable {
        require(block.timestamp < auctionEndTimes[auctionId], "Auction already ended");
        require(msg.value > 0, "Bid amount must be greater than 0");

        auctionBids[auctionId].push(Bid(msg.value, msg.sender));
        pendingReturns[msg.sender] += msg.value;

        // Optimized: Track highest bid during the iteration
        uint256 highestBid = 0;
        address highestBidder;
        Bid[] storage bids = auctionBids[auctionId];
        for (uint256 i = 0; i < bids.length; ++i) {
            if (bids[i].amount > highestBid) {
                highestBid = bids[i].amount;
                highestBidder = bids[i].bidder;
            }
        }

        auctionWinners[auctionId] = highestBidder;
        emit NewBid(auctionId, msg.sender, msg.value);
    }

    function endAuction(uint256 auctionId) public {
        require(block.timestamp >= auctionEndTimes[auctionId], "Auction not yet ended");
        require(auctionWinners[auctionId] != address(0), "No winner determined");

        address winner = auctionWinners[auctionId];
        uint256 highestBid = 0;

        Bid[] storage bids = auctionBids[auctionId];
        for (uint256 i = 0; i < bids.length; ++i) {
            if (bids[i].bidder == winner) {
                highestBid = bids[i].amount;
                break;
            }
        }

        pendingReturns[winner] -= highestBid;
        auctionEndTimes[auctionId] = 0;
        delete auctionBids[auctionId];

        emit AuctionEnded(auctionId, winner, highestBid);
    }

    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingReturns[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function recursiveComputation(uint256 depth) public pure returns (uint256) {
        if (depth == 0) return 1;
        return depth * recursiveComputation(depth - 1);
    }

    function heavyCalculation(uint256 auctionId, uint256 depth) public view returns (uint256) {
        require(auctionId <= auctionCount, "Auction does not exist");

        uint256 result = 0;
        Bid[] storage bids = auctionBids[auctionId];
        for (uint256 i = 0; i < bids.length; ++i) {
            result += bids[i].amount * recursiveComputation(depth);
        }
        return result;
    }
}
