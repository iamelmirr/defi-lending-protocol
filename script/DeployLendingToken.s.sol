// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {LendingToken} from "../src/LendingToken.sol";

contract DeployLendingToken is Script {
    function run() external returns (LendingToken) {
        vm.startBroadcast();

        LendingToken lendingToken = new LendingToken();

        vm.stopBroadcast();

        return lendingToken;
    }
}
