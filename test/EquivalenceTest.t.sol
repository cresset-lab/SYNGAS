// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "halmos-cheatcodes/SymTest.sol";
import "forge-std/Test.sol";

// ---------------------------------------------------------
// 1. The Original Contract (Safe, Readable, Expensive)
// ---------------------------------------------------------
contract Original {
    // A standard function that sums numbers from 0 to n
    // Uses default Solidity 0.8+ checked arithmetic (reverts on overflow)
    function sumSeries(uint256 n) public pure returns (uint256 sum) {
        for (uint256 i = 0; i <= n; i++) {
            sum += i; 
        }
        return sum;
    }
}

// ---------------------------------------------------------
// 2. The Optimized Contract (Aggressive, Hard to Read, Cheap)
// ---------------------------------------------------------
contract Optimized {
    // The same logic, but optimized for gas:
    // - Unchecked arithmetic (risky if not analyzed)
    // - Pre-increments (++i)
    // - Specific Yul-style optimization patterns
    function sumSeries(uint256 n) public pure returns (uint256 sum) {
        unchecked {
            for (uint256 i = 0; i <= n; ++i) {
                sum += i;
            }
        }
        return sum;
    }
}

// ---------------------------------------------------------
// 3. The Equivalence Harness (The "Miter")
// ---------------------------------------------------------
contract EquivalenceTest is SymTest, Test {
    Original original;
    Optimized optimized;

    function setUp() public {
        original = new Original();
        optimized = new Optimized();
    }

    // Halmos will treat 'n' as a SYMBOLIC variable (all possible uint256 values simultaneously).
    // We cap 'n' to a reasonable symbolic bound (e.g., 100) to keep the solver fast for loops,
    // or we can verify the mathematical formula n*(n+1)/2 directly.
    function check_equivalence_sumSeries(uint256 n) public {
        
        // CONSTRAINT: To prevent infinite loop unrolling during proof, 
        // we restrict the symbolic domain of n.
        // In a real paper, you would use loop invariants to prove this for *all* n.
        vm.assume(n < 100); 

        // 1. Execute Original
        // We use low-level call to capture reverts safely
        (bool success1, bytes memory data1) = address(original).call(
            abi.encodeWithSelector(Original.sumSeries.selector, n)
        );

        // 2. Execute Optimized
        (bool success2, bytes memory data2) = address(optimized).call(
            abi.encodeWithSelector(Optimized.sumSeries.selector, n)
        );

        // 3. PROOF: Revert Equivalence
        // If Original reverts (e.g., overflow), Optimized MUST also revert.
        // If Optimized succeeds, Original MUST succeed.
        assert(success1 == success2);

        // 4. PROOF: Return Value Equivalence
        // If both succeeded, the resulting bytes (outputs) must be bit-for-bit identical.
        if (success1) {
            uint256 result1 = abi.decode(data1, (uint256));
            uint256 result2 = abi.decode(data2, (uint256));
            assert(result1 == result2);
        }
    }
    
    // ---------------------------------------------------------
    // Bonus: Detecting a Bug in an "Over-Optimized" version
    // ---------------------------------------------------------
    function check_bug_detection(uint256 n) public {
        vm.assume(n < 100);
        
        // Imagine an optimized version that accidentally calculates (n * n) / 2
        // instead of n * (n + 1) / 2
        uint256 wrong_optimization = (n * n) / 2;
        
        try original.sumSeries(n) returns (uint256 res) {
            // This assertion will FAIL and Halmos will give you the counter-example
            // showing exactly which 'n' breaks the optimization.
            // Uncomment to test:
            // assert(res == wrong_optimization); 
        } catch {
            // If original reverts, we ignore (handled in assume)
        }
    }
}