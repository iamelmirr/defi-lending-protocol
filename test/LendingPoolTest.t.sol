// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {LendingToken} from "../src/LendingToken.sol";

contract LendingPoolTest is Test {
    LendingPool public lendingPool;
    LendingToken public lendingToken;
    address public user1;
    address public user2;
    address public owner;

    function setUp() public {
        lendingToken = new LendingToken();
        lendingPool = new LendingPool(address(lendingToken));

        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        lendingToken.mint(user1, 1000 ether);
        lendingToken.mint(user2, 1000 ether);

        vm.prank(user1);
        lendingToken.approve(address(lendingPool), 1000 ether);

        vm.prank(user2);
        lendingToken.approve(address(lendingPool), 1000 ether);
    }

    function testDepositSuccess() public {
        uint256 depositAmount = 100 ether;

        vm.prank(user1);
        lendingPool.deposit(depositAmount);

        uint256 userDeposit = lendingPool.getUserDeposit(user1);
        assertEq(userDeposit, depositAmount);
    }

    function testCannotDepositZero() public {
        vm.prank(user1);
        vm.expectRevert(LendingPool.LendingPool__LendingPoolCannotDepositZero.selector);
        lendingPool.deposit(0);
    }

    function testWithdraw() public {
        uint256 depositAmount = 100 ether;
        uint256 withdrawAmount = 50 ether;

        vm.prank(user1);
        lendingPool.deposit(depositAmount);

        vm.prank(user1);
        lendingPool.withdraw(withdrawAmount);

        uint256 userDeposit = lendingPool.getUserDeposit(user1);
        assertEq(userDeposit, depositAmount - withdrawAmount);

        uint256 totalDeposits = lendingPool.totalDeposits();
        assertEq(totalDeposits, depositAmount - withdrawAmount);
    }

    function testCannotWithdrawZero() public {
        vm.prank(user1);
        vm.expectRevert(LendingPool.LendingPool__LendingPoolCannotWithdrawZero.selector);
        lendingPool.withdraw(0);
    }

    function testInsufficientBalance() public {
        uint256 depositAmount = 100 ether;
        uint256 withdrawAmount = 150 ether;

        vm.prank(user1);
        lendingPool.deposit(depositAmount);

        vm.prank(user1);
        vm.expectRevert();
        lendingPool.withdraw(withdrawAmount);
    }

    function testInterestCalculation() public {
        uint256 depositAmount = 100 ether;

        vm.prank(user1);
        lendingPool.deposit(depositAmount);

        vm.warp(block.timestamp + 1 days);

        uint256 interest = lendingPool.calculateInterest(user1);
        assertGt(interest, 0);
    }
}
