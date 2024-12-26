// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {IZUSD} from "src/IZUSD.sol";
import {LSToken} from "src/LSToken.sol";
import {zUSD} from "src/zUSD.sol";
import {ZekaeVault} from "src/ZekaeVault.sol";
import {Test, console} from "forge-std/Test.sol";

contract ZekaeVaultTest is Test {
    LSToken public lstoken;
    zUSD public zusd;
    ZekaeVault public zekaeVault;
    address public constant USER = address(1);
    uint256 public constant lstokenPriceAtCreation = 10e18;

    function setUp() public {
        lstoken = new LSToken(USER);
        zusd = new zUSD(USER);
        zekaeVault = new ZekaeVault(address(lstoken), address(zusd), lstokenPriceAtCreation);
        vm.startPrank(USER);
        zusd.changeOwner(address(zekaeVault));
        vm.stopPrank();
    }

    function test_lstokenOwner() public view {
        assertEq(address(lstoken.owner()), USER);
    }

    function test_zUSDOwner() public view {
        assertEq(address(zusd.owner()), address(zekaeVault));
    }

    function test_ZekaeVaultDepositAndMint() public {
        vm.startPrank(USER);
        lstoken.mint(USER, 1000000e18);
        lstoken.approve(address(zekaeVault), 1000e18);
        zekaeVault.deposit(1000e18);
        zekaeVault.mint(100e18);
        vm.stopPrank();
        assertEq(lstoken.balanceOf(USER), 999000e18);
        assertEq(zusd.balanceOf(USER), 100e18);
    }
}
