// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console } from "forge-std/Script.sol";
import { L2Slpx } from "src/L2Slpx/L2Slpx.sol";
import { zUSD } from "src/zUSD.sol";
import { ZekaeVault } from "src/ZekaeVault.sol";
import { SimpleOracle } from "src/SimpleOracle.sol";

contract Deploy is Script {
    function run() external returns (address zusdAddress, address vaultAddress, address oracleAddress) {
        /// @dev declare the address of the owner
        address OWNER = 0x6FaFF29226219756aa40CE648dbc65FB41DE5F72;
        address LIQUIDATOR = 0x6FaFF29226219756aa40CE648dbc65FB41DE5F72;
        address VETH = 0x6e0f9f2d25CC586965cBcF7017Ff89836ddeF9CC;
        address L2SLPX = 0x262e52beD191a441CBD28dB151A11D7c41384F72;

        console.log("Starting deployment on sepolia");
        vm.startBroadcast();
        SimpleOracle oracle = new SimpleOracle(OWNER, L2SLPX, VETH);
        oracle.setLatestAnswer(1826e18);
        zUSD zusd = new zUSD(OWNER);
        ZekaeVault vault = new ZekaeVault(VETH, address(zusd), L2SLPX, address(oracle), LIQUIDATOR);
        zusd.transferOwnership(address(vault));
        vm.stopBroadcast();

        /// @dev return the counterAddress
        return (address(zusd), address(vault), address(oracle));
    }
}