// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {BaseSlpx} from "src/BaseSlpx.sol";
import {vETH} from "src/vETH.sol";
import {Gateway} from "src/Gateway.sol";
import {Test, console} from "forge-std/Test.sol";

contract BaseSlpxTest is Test {

    BaseSlpx public baseSlpx;
    vETH public veth;
    Gateway public gateway;
    address public constant USER = address(1);
    uint256 public constant initialExchangeRate = 1.4e18;
    uint256 public constant initialSendTokenFee = 1000000;
    uint128 public destinationFee = 1000000; // set at 1000000
    uint32 public paraId = 2030; // set at 2030
    uint128 public protocolFee = 1000000; // set at 1000000


    function setUp() public {
        veth = new vETH(USER);
        gateway = new Gateway(initialSendTokenFee, initialExchangeRate, USER);
        baseSlpx = new BaseSlpx(address(gateway), address(veth), destinationFee, protocolFee, paraId, USER);
        vm.deal(USER, 1000 ether);
        vm.startPrank(USER);
        veth.transferOwnership(address(baseSlpx));
        vm.stopPrank();
    }

    function test_ownerVeth() public view {
        assertEq(veth.owner(), address(baseSlpx));
    }

    function test_ownerGateway() public view {
        assertEq(gateway.owner(), USER);
    }

    function test_ownerBaseSlpx() public view {
        assertEq(baseSlpx.owner(), USER);
    }

    function test_gatewayExchangeRate() public view {
        assertEq(gateway.quoteExchangeRate(address(veth), paraId, destinationFee), initialExchangeRate);
    }

    function test_gatewaySendTokenFee() public view {
        assertEq(gateway.quoteSendTokenFee(address(veth), paraId, destinationFee), initialSendTokenFee);
    }

    function test_mint() public {
        vm.startPrank(USER);
        baseSlpx.mint{value: 14 ether}();
        vm.stopPrank();
        assertEq(veth.balanceOf(USER), 10_000_000_000_000_000_000);
    }
}


