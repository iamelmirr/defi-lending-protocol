// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {DeployLendingToken} from "./DeployLendingToken.s.sol";

contract DeployLendingPool is Script {
    DeployLendingToken tokenDeployer = new DeployLendingToken();

    function run() external returns (LendingPool) {
        vm.startBroadcast();
        LendingPool lendingPool = new LendingPool(address(tokenDeployer));
        vm.stopBroadcast();

        return (lendingPool);
    }
}
