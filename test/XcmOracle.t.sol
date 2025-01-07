// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {XcmOracle} from "src/XcmOracle.sol";
import {Test, console} from "forge-std/Test.sol";

contract XcmOracleTest is Test {
    XcmOracle public xcmOracle;
    address public constant OWNER = address(1);
    address public constant USER = address(2);

    function setUp() public {
        xcmOracle = new XcmOracle(OWNER);
        vm.startPrank(OWNER);
        xcmOracle.setRate(0, 10);
        xcmOracle.setTokenAmount(bytes2(0x0001), 140000, 100000);
        xcmOracle.setAddressToCurrencyId(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, bytes2(0x0001));
        vm.stopPrank();
        vm.deal(USER, 1000 ether);
    }

    function test_OwnerXcmOracle() public view {
        assertEq(xcmOracle.owner(), OWNER);
    }

    function test_CurrencyIdOfNativeEth() public view {
        bytes2 currencyId = xcmOracle.getCurrencyIdByAssetAddress(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        assertEq(currencyId, bytes2(0x0001));
    }

    function test_GetVTokenByToken() public view {
        uint256 vTokenAmount = xcmOracle.getVTokenByToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 140);
        assertEq(vTokenAmount, 100);
    }

    function test_GetTokenByVToken() public view {
        uint256 tokenAmount = xcmOracle.getTokenByVToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 100);
        assertEq(tokenAmount, 140);
    }
}
