// SPDX-License-Identifier: MIT
// Auto-generated equivalence test
// Generated: 2025-12-09 18:31:32
pragma solidity ^0.8.20;

import "halmos-cheatcodes/SymTest.sol";
import "forge-std/Test.sol";
import {Original} from "../benchmark/06_Reentrancy_Protection/Original.sol";
import {Aggressive} from "../llm_optimized/OriginalOpt_iter1.sol";

/**
 * @title Auto-Generated Equivalence Test
 * @notice Symbolically verifies that Original and Aggressive are equivalent
 */
contract AutoEquivalenceTest is SymTest, Test {
    Original original;
    Aggressive optimized;

    function setUp() public {
        original = new Original();
        optimized = new Aggressive();
        assertStateEquivalence();
    }

    /**
     * @notice Verifies that both contracts have equivalent state
     */
    function assertStateEquivalence() internal {
        // No public state variables found to check
    }

    /**
     * @notice Generic function equivalence checker
     * @dev Internal to prevent Halmos from testing with arbitrary inputs
     */
    function check_function_equivalence(
        bytes4 selector,
        bytes memory args
    ) internal {
        (bool success1, bytes memory returnData1) = address(original).call(
            abi.encodePacked(selector, args)
        );

        (bool success2, bytes memory returnData2) = address(optimized).call(
            abi.encodePacked(selector, args)
        );

        assert(success1 == success2);

        if (success1 && success2) {
            assert(keccak256(returnData1) == keccak256(returnData2));
        }
        
        assertStateEquivalence();
    }

    function check_equivalence_deposit(uint256 amount) public {
        // Constraints
        vm.assume(amount < 150);

        check_function_equivalence(
            original.deposit.selector,
            abi.encode(amount)
        );
    }


    function check_equivalence_withdraw(uint256 amount) public {
        // Constraints
        vm.assume(amount < 150);

        // First, deposit funds to enable withdrawal (need 2x for reentrancy test)
        (bool dep_success1, ) = address(original).call(
            abi.encodeWithSelector(original.deposit.selector, amount * 2)
        );
        (bool dep_success2, ) = address(optimized).call(
            abi.encodeWithSelector(optimized.deposit.selector, amount * 2)
        );
        require(dep_success1 && dep_success2, "Deposit failed");
        assertStateEquivalence();

        // Test reentrancy: Original has protection, optimized doesn't
        // First call should succeed for both
        (bool success1_1, bytes memory returnData1_1) = address(original).call(
            abi.encodePacked(original.withdraw.selector, abi.encode(amount))
        );
        (bool success2_1, bytes memory returnData2_1) = address(optimized).call(
            abi.encodePacked(optimized.withdraw.selector, abi.encode(amount))
        );
        
        // Both first calls should succeed
        assert(success1_1 == success2_1);
        if (success1_1 && success2_1) {
            assert(keccak256(returnData1_1) == keccak256(returnData2_1));
        }
        assertStateEquivalence();
        
        // Second call: original should fail (reentrancy protection), optimized might succeed
        (bool success1_2, bytes memory returnData1_2) = address(original).call(
            abi.encodePacked(original.withdraw.selector, abi.encode(amount))
        );
        (bool success2_2, bytes memory returnData2_2) = address(optimized).call(
            abi.encodePacked(optimized.withdraw.selector, abi.encode(amount))
        );
        
        // Original should revert on second call (reentrancy protection)
        // Optimized might succeed (this is the bug)
        // If optimized also reverts, they're equivalent (no bug)
        // If optimized succeeds but original reverts, that's the bug
        assert(success1_2 == success2_2);
        
        if (success1_2 && success2_2) {
            assert(keccak256(returnData1_2) == keccak256(returnData2_2));
        }
        assertStateEquivalence();
    }

}
