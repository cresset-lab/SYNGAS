// SPDX-License-Identifier: MIT
// Auto-generated equivalence test
// Generated: 2026-01-26 13:20:56
pragma solidity ^0.8.20;

import "halmos-cheatcodes/SymTest.sol";
import "forge-std/Test.sol";
import {A} from "../src/A.sol";
import {AOpt} from "../llm_optimized/AOpt_iter2.sol";

/**
 * @title Auto-Generated Equivalence Test
 * @notice Symbolically verifies that A and AOpt are equivalent
 */
contract AutoEquivalenceTest is SymTest, Test {
    A original;
    AOpt optimized;

    function setUp() public {
        original = new A();
        optimized = new AOpt();
        assertStateEquivalence();
    }

    /**
     * @notice Verifies that both contracts have equivalent state
     */
    function assertStateEquivalence() internal {
        assert(original.res() == optimized.res());
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

    function check_equivalence_bar() public {
        // Constraints
        // No constraints needed

        check_function_equivalence(
            original.bar.selector,
            ""
        );
    }


    function check_equivalence_foo() public {
        // Constraints
        // No constraints needed

        check_function_equivalence(
            original.foo.selector,
            ""
        );
    }


    function check_equivalence_fooBar() public {
        // Constraints
        // No constraints needed

        check_function_equivalence(
            original.fooBar.selector,
            ""
        );
    }


}
