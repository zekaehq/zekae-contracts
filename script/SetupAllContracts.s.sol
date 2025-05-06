// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console } from "forge-std/Script.sol";
import { L2Slpx } from "src/L2Slpx/L2Slpx.sol";
import { ICREATE3Factory } from "lib/create3-factory/ICREATE3Factory.sol";
import { vETH } from "src/L2Slpx/vETH.sol";
import { vDOT } from "src/L2Slpx/vDOT.sol";
import { DOT } from "src/L2Slpx/DOT.sol";

contract SetupAllContracts is Script {
    function run() external {
        /// @dev declare the address of the owner
        address l2SlpxAddress = 0xb89604dEBD757936cAA6bE39d158C866a8FD002e;
        address vETHAddress = 0x435e70Bf1269c8dE264e06702AE1222aE9634982;
        address vDOTAddress = 0x8Fd0A1674aF068c46bfAd3B266C522298B14187F;
        address DOTAddress = 0xB8Fd9BB1b32BbCd2F00913115584a07E1393d1d0;
        uint256 MIN_ETH_ORDER_AMOUNT = 0.001 ether;
        uint256 ETH_TO_VETH_TOKEN_CONVERSION_RATE = 0.898e18;
        uint256 ETH_ORDER_FEE = 0.01e18;
        uint256 MIN_DOT_ORDER_AMOUNT = 1 ether;
        uint256 DOT_TO_VDOT_TOKEN_CONVERSION_RATE = 0.6646e18;
        uint256 DOT_ORDER_FEE = 0.01e18;

        console.log("Starting setup on sepolia");
        /// @dev select the sepolia network
        vm.createSelectFork("sepolia");
        /// @dev start the broadcast
        vm.startBroadcast();

        L2Slpx(l2SlpxAddress).setTokenConversionInfo(address(0), L2Slpx.Operation.Mint, MIN_ETH_ORDER_AMOUNT, ETH_TO_VETH_TOKEN_CONVERSION_RATE, ETH_ORDER_FEE, vETHAddress);
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(DOTAddress, L2Slpx.Operation.Mint, MIN_DOT_ORDER_AMOUNT, DOT_TO_VDOT_TOKEN_CONVERSION_RATE, DOT_ORDER_FEE, vDOTAddress);
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(vETHAddress, L2Slpx.Operation.Redeem, MIN_ETH_ORDER_AMOUNT, ETH_TO_VETH_TOKEN_CONVERSION_RATE, ETH_ORDER_FEE, address(0));
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(vDOTAddress, L2Slpx.Operation.Redeem, MIN_DOT_ORDER_AMOUNT, DOT_TO_VDOT_TOKEN_CONVERSION_RATE, DOT_ORDER_FEE, DOTAddress);

        vm.stopBroadcast();

        console.log("Starting setup on base-sepolia");
        /// @dev select the base-sepolia network
        vm.createSelectFork("base-sepolia");
        /// @dev start the broadcast
        vm.startBroadcast();
        /// @dev call the deploy function of the CREATE3Factory contract to deploy the Counter contract with the salt
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(address(0), L2Slpx.Operation.Mint, 0.001 ether, 0.898e18, 0.01e18, vETHAddress);
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(DOTAddress, L2Slpx.Operation.Mint, 1 ether, 0.6646e18, 0.01e18, vDOTAddress);
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(address(0), L2Slpx.Operation.Redeem, 0.001 ether, 0.898e18, 0.01e18, vETHAddress);
        L2Slpx(l2SlpxAddress).setTokenConversionInfo(DOTAddress, L2Slpx.Operation.Redeem, 1 ether, 0.6646e18, 0.01e18, vDOTAddress);
        /// @dev stop the broadcast
        vm.stopBroadcast();
    }
}