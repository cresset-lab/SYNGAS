// SPDX-License-Identifier: MIT
// Auto-generated equivalence test
// Generated: 2025-12-09 17:25:26
pragma solidity ^0.8.20;

import "halmos-cheatcodes/SymTest.sol";
import "forge-std/Test.sol";
import {Original} from "../benchmark/24_Overflow_Edge/Original.sol";
import {Optimized} from "../benchmark/24_Overflow_Edge/Optimized.sol";

/**
 * @title Auto-Generated Equivalence Test
 * @notice Symbolically verifies that Original and Optimized are equivalent
 */
contract AutoEquivalenceTest is SymTest, Test {
    Original original;
    Optimized optimized;

    function setUp() public {
        original = new Original();
        optimized = new Optimized();
        assertStateEquivalence();
    }

    /**
     * @notice Verifies that both contracts have equivalent state
     */
    function assertStateEquivalence() internal {
        assert(original.MAX() == optimized.MAX());
        assert(original.total() == optimized.total());
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

    function check_equivalence_add(uint256 amount) public {
        // Constraints
        vm.assume(amount < 150);

        check_function_equivalence(
            original.add.selector,
            abi.encode(amount)
        );
    }

    function check_equivalence_subtract(uint256 amount) public {
        // Constraints
        vm.assume(amount < 150);

        check_function_equivalence(
            original.subtract.selector,
            abi.encode(amount)
        );
    }

}
