// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {BaseSlpx} from "src/BaseSlpx.sol";
import {vETH} from "src/vETH.sol";
import {Gateway} from "src/Gateway.sol";
import {XcmOracle} from "src/XcmOracle.sol";
import {YieldDelegationVault} from "src/YieldDelegationVault.sol";
import {Test, console} from "forge-std/Test.sol";

contract BaseSlpxTest is Test {
    BaseSlpx public baseSlpx;
    vETH public veth;
    Gateway public gateway;
    XcmOracle public xcmOracle;
    YieldDelegationVault public yieldDelegationVault;
    address public constant OWNER = address(1);
    address public constant USER = address(2);
    uint256 public constant initialExchangeRate = 1.4e18;
    uint256 public constant initialSendTokenFee = 1000000;
    uint128 public destinationFee = 1000000; // set at 1000000
    uint32 public paraId = 2030; // set at 2030
    uint128 public protocolFee = 1000000; // set at 1000000

    function setUp() public {
        veth = new vETH(OWNER);
        gateway = new Gateway(initialSendTokenFee, initialExchangeRate, OWNER);
        baseSlpx = new BaseSlpx(address(gateway), address(veth), destinationFee, protocolFee, paraId, OWNER);
        xcmOracle = new XcmOracle(OWNER);
        yieldDelegationVault = new YieldDelegationVault(address(xcmOracle), address(veth), OWNER);
        vm.deal(USER, 1000 ether);
        vm.startPrank(OWNER);
        veth.transferOwnership(address(baseSlpx));
        vm.stopPrank();
    }

    function test_OwnerVeth() public view {
        assertEq(veth.owner(), address(baseSlpx));
    }

    function test_OwnerGateway() public view {
        assertEq(gateway.owner(), OWNER);
    }

    function test_OwnerBaseSlpx() public view {
        assertEq(baseSlpx.owner(), OWNER);
    }

    function test_GatewayExchangeRate() public view {
        assertEq(gateway.quoteExchangeRate(address(veth), paraId, destinationFee), initialExchangeRate);
    }

    function test_GatewaySendTokenFee() public view {
        assertEq(gateway.quoteSendTokenFee(address(veth), paraId, destinationFee), initialSendTokenFee);
    }

    function test_Mint() public {
        vm.startPrank(USER);
        baseSlpx.mint{value: 14 ether}();
        vm.stopPrank();
        assertEq(veth.balanceOf(USER), 10_000_000_000_000_000_000);
    }
}
