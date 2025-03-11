// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LendingToken} from "./LendingToken.sol";

contract LendingPool is Ownable {
    error LendingPool__LendingPoolCannotDepositZero();
    error LendingPool__LendingPoolCannotWithdrawZero();
    error LendingPool__LendingPoolInsufficientBalance();
    error LendingPool__LendingPoolDepositFailed();
    error LendingPool__LendingPoolWithdrawFailed();

    LendingToken public immutable token;
    uint256 public interestRate = 5;
    uint256 public totalDeposits;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public lastDepositTime;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = LendingToken(_token);
    }

    function deposit(uint256 amount) public {
        if (amount <= 0) {
            revert LendingPool__LendingPoolCannotDepositZero();
        }

        bool success = token.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert LendingPool__LendingPoolDepositFailed();
        }

        if (deposits[msg.sender] > 0) {
            uint256 interest = calculateInterest(msg.sender);
            deposits[msg.sender] += interest;
        }

        deposits[msg.sender] += amount;
        lastDepositTime[msg.sender] = block.timestamp;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        if (amount <= 0) {
            revert LendingPool__LendingPoolCannotWithdrawZero();
        }

        uint256 interest = calculateInterest(msg.sender);
        uint256 totalAmount = deposits[msg.sender] + interest;

        if (deposits[msg.sender] < totalAmount) {
            revert LendingPool__LendingPoolInsufficientBalance();
        }

        bool success = token.transfer(msg.sender, amount);
        if(!success) {
            revert LendingPool__LendingPoolWithdrawFailed();
        }

        deposits[msg.sender] = totalAmount - amount;
        lastDepositTime[msg.sender] = block.timestamp;
        totalDeposits -= amount;

        emit Withdrawn(msg.sender, amount);
    }

    function calculateInterest(address user) public view returns (uint256) {
        if (lastDepositTime[user] != 0) {
            uint256 timeElapsed = block.timestamp - lastDepositTime[user];
            uint256 interest = (deposits[user] * interestRate * timeElapsed) / (365 days * 100);
            return interest;
        } else {
            return 0;
        }
    }

    function getUserDeposit(address user) external view returns (uint256 amount) {
        amount = deposits[user];
        return amount;
    }
}
