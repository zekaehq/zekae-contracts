// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {XcmOracle} from "src/XcmOracle.sol";
import {Test, console} from "forge-std/Test.sol";

contract XcmOracleTest is Test {

    XcmOracle public xcmOracle;
    address public constant OWNER = address(1);
    address public constant USER = address(2);
    uint256 public constant initialExchangeRate = 1.4e18;
    uint256 public constant initialSendTokenFee = 1000000;
    uint128 public destinationFee = 1000000; // set at 1000000
    uint32 public paraId = 2030; // set at 2030
    uint128 public protocolFee = 1000000; // set at 1000000


    function setUp() public {
        xcmOracle = new XcmOracle(OWNER);
        vm.deal(USER, 1000 ether);
    }

    function test_ownerXcmOracle() public view {
        assertEq(xcmOracle.owner(), OWNER);
    }
}


