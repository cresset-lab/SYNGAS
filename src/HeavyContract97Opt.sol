
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract97Opt {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    mapping(uint256 => Bid[]) public auctionBids;
    mapping(uint256 => address) public auctionWinners;
    uint256 public auctionCounter;
    uint256 public constant MAX_BIDS = 100;
    uint256 public constant ITERATIONS = 1000;

    function startAuction() public returns (uint256) {
        return auctionCounter++;
    }

    function placeBid(uint256 auctionId, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        Bid[] storage bids = auctionBids[auctionId];
        require(bids.length < MAX_BIDS, "Max bids reached for this auction");

        bids.push(Bid({bidder: msg.sender, amount: amount}));

        // Optimized gas: Avoid repeated storage lookups.
        uint256 len = bids.length;
        for (uint256 i = 0; i < len; ) {
            bids[i].amount ^= amount;
            unchecked { ++i; }
        }

        updateAuctionWinner(auctionId);
    }

    function updateAuctionWinner(uint256 auctionId) internal {
        Bid[] storage bids = auctionBids[auctionId];
        uint256 highestBid = 0;
        address highestBidder;

        uint256 len = bids.length;
        for (uint256 i = 0; i < len; ) {
            uint256 currentBidAmount = bids[i].amount;
            if (currentBidAmount > highestBid) {
                highestBid = currentBidAmount;
                highestBidder = bids[i].bidder;
            }
            unchecked { ++i; }
        }

        auctionWinners[auctionId] = highestBidder;
    }

    function heavyComputation(uint256 seed) public pure returns (uint256) {
        uint256 result = seed;
        
        // Optimize: Use unchecked block to save gas, and reduce repeated operations.
        for (uint256 i = 0; i < ITERATIONS; ) {
            result = ((result << 1) | (result >> 31)) ^ seed;
            unchecked { ++i; }
        }

        return result;
    }

    function intensiveLoop(uint256[] calldata data) public pure returns (uint256) {
        uint256 sum = 0;
        uint256 data_len = data.length;

        for (uint256 i = 0; i < data_len; ) {
            for (uint256 j = 0; j < data_len; ) {
                sum += (data[i] ^ data[j]) % (j + 1);
                unchecked { ++j; }
            }
            unchecked { ++i; }
        }

        return sum;
    }

    function recursiveCalculation(uint256 n) public pure returns (uint256) {
        if (n <= 1) {
            return n;
        }
        // Recursive calls optimized (unchanged for correctness but show intent)
        uint256 a = recursiveCalculation(n - 1);
        uint256 b = recursiveCalculation(n - 2);
        return a ^ b;
    }
}
