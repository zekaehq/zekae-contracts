// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {L2Slpx} from "src/L2Slpx/L2Slpx.sol";
import {vETH} from "src/L2Slpx/vETH.sol";
import {vDOT} from "src/L2Slpx/vDOT.sol";
import {DOT} from "src/L2Slpx/DOT.sol";
import {IVToken} from "src/L2Slpx/IVToken.sol";
import {Test, console} from "forge-std/Test.sol";

contract L2SlpxTest is Test {
    address public constant OWNER = address(1);
    address public constant USER = address(2);
    address public constant DOT_OWNER = address(3);
    uint256 public constant initialExchangeRate = 1.4e18;
    uint256 public constant initialSendTokenFee = 1000000;

    L2Slpx public l2Slpx;
    vETH public veth;
    vDOT public vdot;
    DOT public dot;

    function setUp() public {
        l2Slpx = new L2Slpx(OWNER);
        veth = new vETH(address(l2Slpx));
        vdot = new vDOT(address(l2Slpx));
        dot = new DOT(DOT_OWNER);
        vm.deal(USER, 1000 ether);
        vm.startPrank(DOT_OWNER);
        dot.mint(USER, 10000e18);
        vm.stopPrank();
        vm.startPrank(OWNER);
        l2Slpx.setTokenConversionInfo(address(0), L2Slpx.Operation.Mint, 0.001 ether, 0.8e18, 0.01e18, address(veth));
        l2Slpx.setTokenConversionInfo(address(dot), L2Slpx.Operation.Mint, 1 ether, 0.7e18, 0.01e18, address(vdot));
        vm.stopPrank();
    }

    function test_createOrderETH() public {
        vm.startPrank(USER);
        l2Slpx.createOrder{value: 1 ether}(address(0), 1 ether, L2Slpx.Operation.Mint, "meme");
        vm.stopPrank();
        assertEq(veth.balanceOf(USER), 0.792e18);
    }

    function test_createOrderERC20() public {
        vm.startPrank(USER);
        dot.approve(address(l2Slpx), 10e18);
        l2Slpx.createOrder(address(dot), 10e18, L2Slpx.Operation.Mint, "meme");
        vm.stopPrank();
        assertEq(vdot.balanceOf(USER), 6.93e18);
    }

    function test_checkSupportToken() public view {
        assertTrue(l2Slpx.checkSupportToken(address(0)));
        assertTrue(l2Slpx.checkSupportToken(address(dot)));
    }

    function test_getTokenConversionInfoETH() public view {
        L2Slpx.TokenConversionInfo memory tokenConversionInfo = l2Slpx.getTokenConversionInfo(address(0));
        assertEq(tokenConversionInfo.minOrderAmount, 0.001 ether);
        assertEq(tokenConversionInfo.tokenConversionRate, 0.8e18);
        assertEq(tokenConversionInfo.orderFee, 0.01e18);
    }

    function test_getTokenConversionInfoERC20() public view {
        L2Slpx.TokenConversionInfo memory tokenConversionInfo = l2Slpx.getTokenConversionInfo(address(dot));
        assertEq(tokenConversionInfo.minOrderAmount, 1 ether);
        assertEq(tokenConversionInfo.tokenConversionRate, 0.7e18);
        assertEq(tokenConversionInfo.orderFee, 0.01e18);
    }

    function test_removeTokenConversionInfo() public {
        vm.startPrank(OWNER);
        l2Slpx.removeTokenConversionInfo(address(0));
        vm.stopPrank();
        L2Slpx.TokenConversionInfo memory tokenConversionInfo = l2Slpx.getTokenConversionInfo(address(0));
        assertEq(tokenConversionInfo.minOrderAmount, 0);
    }
}                   