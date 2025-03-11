// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {LendingPool} from "../../src/LendingPool.sol";
import {LendingToken} from "../../src/LendingToken.sol";

contract LendingPoolFuzzTest is Test {
    LendingPool public lendingPool;
    LendingToken public lendingToken;

    address public user1;

    function setUp() public {
        lendingToken = new LendingToken();
        lendingPool = new LendingPool(address(lendingToken));
        user1 = makeAddr('user1');

        lendingToken.mint(user1, 1000 ether);

        vm.prank(user1);
        lendingToken.approve(address(lendingPool), 1000 ether);
    }

    function testFuzzDeposit(uint256 amount) public {
        if (amount <= 0 || amount > 1000 ether) {
            return;
        }

        vm.prank(user1);
        lendingPool.deposit(amount);

        uint256 userDeposit = lendingPool.getUserDeposit(user1);
        assertEq(userDeposit, amount);
    }

    function testFuzzWithdraw(uint256 amount) public {
        uint256 depositAmount = 1000 ether;

        vm.prank(user1);
        lendingPool.deposit(depositAmount);

        if(amount <= 0 || amount > depositAmount) {
            return;
        }

        vm.prank(user1);
        lendingPool.withdraw(amount);

        uint256 userDeposit = lendingPool.getUserDeposit(user1);
        assertEq(userDeposit, depositAmount - amount);
    }

}