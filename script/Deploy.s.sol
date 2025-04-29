// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { DeployHelper } from "script/DeployHelper.s.sol";

contract Deploy is Script {
    function run() external {
        /// @dev initialize the DeployHelper contract
        DeployHelper deployHelper = new DeployHelper();

        /// @dev get the active network configuration using the DeployHelper contract
        (address dataFeed, address coordinator, bytes32 keyHash, uint64 accountId, address pythDataFeed) =
            deployHelper.activeNetworkConfig();

        /// @dev start the broadcast
        vm.startBroadcast();


        /// @dev stop the broadcast
        vm.stopBroadcast();

        /// @dev return the Counter and DeployHelper contracts
        return (luckyDraw, tokenERC20, deployHelper);
    }
}