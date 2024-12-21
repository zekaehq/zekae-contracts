// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {IKUSD} from "src/IKUSD.sol";
import {StKAIA} from "src/stKAIA.sol";
import {KUSD} from "src/kUSD.sol";
import {stKAIAVault} from "src/stKAIAVault.sol";
import {Test, console} from "forge-std/Test.sol";

contract stKAIAVaultTest is Test {
    StKAIA public stkaia;
    KUSD public kusd;
    stKAIAVault public stkaiaVault;
    address public constant USER = address(1);
    uint256 public constant stKAIA_PRICE_AT_CREATION = 10e18;

    function setUp() public {
        stkaia = new StKAIA(USER);
        kusd = new KUSD(USER);
        stkaiaVault = new stKAIAVault(address(stkaia), address(kusd), stKAIA_PRICE_AT_CREATION);
        vm.startPrank(USER);
        kusd.changeOwner(address(stkaiaVault));
        vm.stopPrank();
    }

    function test_stKAIAOwner() public view {
        assertEq(address(stkaia.owner()), USER);
    }

    function test_kUSDOwner() public view {
        assertEq(address(kusd.owner()), address(stkaiaVault));
    }

    function test_stKAIAVaultDepositAndMint() public {
        vm.startPrank(USER);
        stkaia.mint(USER, 1000000e18);
        stkaia.approve(address(stkaiaVault), 1000e18);
        stkaiaVault.deposit(1000e18);
        stkaiaVault.mint(100e18);
        vm.stopPrank();
        assertEq(stkaia.balanceOf(USER), 999000e18);
        assertEq(kusd.balanceOf(USER), 100e18);
    }
}