// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {DeployHamToken} from "script/DeployHamToken.s.sol";
import {HamToken} from "src/HamToken.sol";

contract TestHamToken is Test {
    HamToken public hamToken;
    DeployHamToken public deployer;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployHamToken();
        hamToken = deployer.run();

        vm.prank(msg.sender);
        hamToken.transfer(bob, STARTING_BALANCE);
    }

    /* -------------------------------------------------------------------------- */
    /* METADATA TESTS                              */
    /* -------------------------------------------------------------------------- */

    // These simple tests ensure your constructor set the variables correctly
    function testMetadata() public {
        assertEq(hamToken.name(), "HamToken");
        assertEq(hamToken.symbol(), "HTK");
        assertEq(hamToken.decimals(), 18);
    }

    /* -------------------------------------------------------------------------- */
    /* BASIC TRANSFERS                             */
    /* -------------------------------------------------------------------------- */

    function testBobBalance() public {
        uint256 bobBalance = hamToken.balanceOf(bob);
        assertEq(bobBalance, STARTING_BALANCE);
    }

    function testTransfer() public {
        uint256 transferAmount = 10 ether;

        // Bob sends 10 tokens to Alice
        vm.prank(bob);
        hamToken.transfer(alice, transferAmount);

        // Check Alice received it
        assertEq(hamToken.balanceOf(alice), transferAmount);

        // Check Bob lost it
        assertEq(hamToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferFailInsufficientBalance() public {
        uint256 tooMuch = STARTING_BALANCE + 1 ether;

        // Expect the next transaction to revert
        vm.expectRevert();
        vm.prank(bob);
        hamToken.transfer(alice, tooMuch);
    }

    /* -------------------------------------------------------------------------- */
    /* ALLOWANCES                                 */
    /* -------------------------------------------------------------------------- */

    function testAllowances() public {
        uint256 allowanceAmount = 50 ether;

        vm.prank(bob);
        hamToken.approve(alice, allowanceAmount);

        uint256 allowance = hamToken.allowance(bob, alice);
        assertEq(allowance, allowanceAmount);
    }

    // This is the most complex standard ERC20 function.
    // It tests if Alice can spend Bob's money when approved.
    function testTransferFrom() public {
        uint256 allowanceAmount = 50 ether;
        uint256 transferAmount = 20 ether;

        // 1. Bob approves Alice to spend 50 ether
        vm.prank(bob);
        hamToken.approve(alice, allowanceAmount);

        // 2. Alice moves 20 ether from Bob's account to herself
        vm.prank(alice);
        // transferFrom(from, to, amount)
        hamToken.transferFrom(bob, alice, transferAmount);

        // 3. Assertions
        assertEq(hamToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(hamToken.balanceOf(alice), transferAmount);

        // The allowance should decrease by the amount transferred (50 - 20 = 30)
        assertEq(hamToken.allowance(bob, alice), allowanceAmount - transferAmount);
    }

    /* -------------------------------------------------------------------------- */
    /* FUZZ TESTING                                */
    /* -------------------------------------------------------------------------- */

    // Foundry will run this test hundreds of times with random `amount` values.
    function testFuzzTransfer(uint256 amount) public {
        // Constraint: We only test valid amounts (1 to Bob's balance)
        vm.assume(amount > 0 && amount <= STARTING_BALANCE);

        vm.prank(bob);
        hamToken.transfer(alice, amount);

        assertEq(hamToken.balanceOf(bob), STARTING_BALANCE - amount);
        assertEq(hamToken.balanceOf(alice), amount);
    }
}
